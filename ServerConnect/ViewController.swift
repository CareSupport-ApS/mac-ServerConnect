//
//  ViewController.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 11/12/2021.
//

import Cocoa



class ViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout, NSAlertDelegate, PathCellDelegate {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return servers.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return servers[section].paths.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let server = servers[indexPath.section]
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PathCell"), for: indexPath) as! PathCell
        item.delegate = self
        item.configureCell(server: server, path: server.paths[indexPath.item])
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ServerHeader"), for: indexPath) as! ServerHeader
        view.configure(server: servers[indexPath.section])
        return view
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: servers[section].description != nil ? 40: 30)
    }
    
    
    func pathCellDidRecieveClick(_ view: PathCell) {
        guard let indexPath = collectionView.indexPath(for: view) else { return }
        presentLoginViewController(indexPath: indexPath)
    }
    

    @IBOutlet weak var companyLabel: NSTextField!
    @IBOutlet weak var logoImage: NSImageView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var subtitleLabel: NSTextField!
    
    weak var popoverCloseDelegate: PopoverCloseDelegate?
    
    @IBAction func helpButtonPressed(_ sender: Any) {
        if let helpUrl = DefaultsHelper.helpURL(), let url =  URL(string: helpUrl) {
            NSWorkspace.shared.open(url)
            }
        
    }
    var servers: [Server] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        servers = DefaultsHelper.getServers()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        // Refresh the servers data
        servers = DefaultsHelper.getServers()
        // Reload the collectionView data
        collectionView.reloadData()
    }

    
    private func setupView() {
        collectionView.isSelectable = true
        let flowLayout = NSCollectionViewFlowLayout()
           flowLayout.minimumInteritemSpacing = 0
           flowLayout.minimumLineSpacing = 0
        collectionView.window?.backgroundColor = .clear
           collectionView.collectionViewLayout = flowLayout
        collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
        collectionView.setDraggingSourceOperationMask(.copy, forLocal: false)

        logoImage.loadImage(from: DefaultsHelper.logoUrl())
        companyLabel.stringValue = DefaultsHelper.companyName()
        subtitleLabel.stringValue = DefaultsHelper.subtitle()
           // 2
           view.wantsLayer = true
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        let server = self.servers[indexPath.section]
        let item = server.paths[indexPath.item]
        guard
              let cell = collectionView.item(at: indexPath) as? PathCell
        else {return nil}
        let mountPath = item.localPath(server: server)
            let fileURL = URL(fileURLWithPath: mountPath)
                
                let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(fileURL.absoluteString, forType: .fileURL)
           
        if let snapshot = snapshotForView(cell.view) {
                    let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
                    let frame = CGRect(origin: CGPoint.zero, size: snapshot.size)
                    draggingItem.setDraggingFrame(frame, contents: snapshot)
                    return pasteboardItem
                }
           
           return pasteboardItem
       }
    
    func snapshotForView(_ view: NSView) -> NSImage? {
        let pdfData = view.dataWithPDF(inside: view.bounds)
        let image = NSImage(data: pdfData)
        return image
    }
        
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let path = servers[indexPath.section].paths[indexPath.item]
        
        return NSSize(width: collectionView.bounds.width - 8, height: path.description != nil ? 70: 40)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let first = indexPaths.first else { return }
            collectionView.selectionIndexPaths = []
    }
    

    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        
        // Iterate through all indexPaths that are intended to be dragged.
        for indexPath in indexPaths {
            // Fetch the specific item using indexPath.
            let server = servers[indexPath.section]
            let item = server.paths[indexPath.item]
            
            // Check the mounted state of the item.
            if !item.isMounted(server: server) {
                // If any of the items is not mounted, dragging should not be allowed.
                return false
            }
        }
        
        // If all items are mounted, allow dragging.
        return true
    }

    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        let windowPoint = collectionView.window?.convertPoint(fromScreen: screenPoint)
           let inside = collectionView.bounds.contains(windowPoint ?? NSPoint.zero)
           
           if !inside {
               // Dragging session ended outside the controller
               popoverCloseDelegate?.closePopover(sender: nil)
           }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return servers.count
    }
    
    static func newInstance() -> ViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ViewController")
          
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
            fatalError("Unable to instantiate ViewController in Main.storyboard")
        }
        return viewcontroller
    }
    
    // Method to present LoginViewController
    func presentLoginViewController(indexPath: IndexPath) {
        let server = servers[indexPath.section]
        let path = server.paths[indexPath.item]
        
        if path.isMounted(server: server) {
            path.showInFinder(server: server)
            return
        }
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil) // Replace "Main" with
        guard let loginVC = storyboard.instantiateController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
        loginVC.receivedServer = server
        loginVC.receivedPath = path
        self.presentAsModalWindow(loginVC)
    }
    }

