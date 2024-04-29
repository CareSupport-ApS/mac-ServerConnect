//
//  PathCell.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 11/12/2021.
//

import Cocoa

protocol PathCellDelegate: AnyObject {
    func pathCellDidRecieveClick(_ view: PathCell)
}


class PathCell: NSCollectionViewItem {
    
    weak var delegate: PathCellDelegate?
    
    @IBOutlet weak var primaryLabel: NSTextField!
    @IBOutlet weak var secondaryLabel: NSTextField!
    
    @IBOutlet weak var statusLabelContainer: NSView!
    @IBOutlet weak var statusLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabelContainer.wantsLayer = true
        statusLabelContainer.layer?.cornerRadius = 10
        statusLabelContainer.layer?.backgroundColor = NSColor.green.withAlphaComponent(0.4).cgColor
        statusLabelContainer.isHidden = true
        // Do view setup here.
    }
    
    
    override func mouseEntered(with event: NSEvent) {
        view.window?.backgroundColor = .lightGray
    }
    
    override func mouseExited(with event: NSEvent) {
        view.window?.backgroundColor = .clear
        
    }
    
    
    func configureCell(path: Path) {
        primaryLabel.stringValue = path.name
        secondaryLabel.stringValue = path.description ?? "Ingen beskrivelse"
        secondaryLabel.toolTip = path.description ?? "Ingen beskrivelse"
        
        if path.isMounted() {
            statusLabelContainer.isHidden = false;
        } else {
            statusLabelContainer.isHidden = true
        }
    }
    
    private var initialMouseDownLocation: CGPoint?
    private var dragDetected: Bool = false
    private let dragThreshold: CGFloat = 5.0
    
    
    override func mouseDown(with event: NSEvent) {
           initialMouseDownLocation = event.locationInWindow
           dragDetected = false
        super.mouseDown(with: event)
       }
    
    override func mouseDragged(with event: NSEvent) {
            guard let initialLocation = initialMouseDownLocation else { return }
            let currentLocation = event.locationInWindow
            let distanceMoved = hypot(currentLocation.x - initialLocation.x, currentLocation.y - initialLocation.y)
            
            if distanceMoved > dragThreshold {
                dragDetected = true
            }
        super.mouseDragged(with: event)
        }
    
    override func mouseUp(with event: NSEvent) {
        if !dragDetected {
            // Not a drag, so handle as a click.
            delegate?.pathCellDidRecieveClick(self)
        }
        // Reset the state for next interaction
        dragDetected = false
    }
    
}
