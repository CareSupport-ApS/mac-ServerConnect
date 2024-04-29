//
//  ServerHeader.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 12/12/2021.
//

import Awesome
import Cocoa

class ServerHeader: NSView {

    
    @IBOutlet weak var sectionTitle: NSTextField!
    
    @IBOutlet weak var sectionLogo: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor(named: NSColor.Name("ServerHeaderBgColor"))!.setFill()
                dirtyRect.fill()
        layer?.cornerRadius = 10
        // Drawing code here.
    }
    
    func configure(server: Server) {
        switch server.method {
        case .afp, .smb:
            sectionLogo.attributedStringValue = Awesome.Solid.server.asAttributedText(fontSize: 16)
        case .web:
            sectionLogo.attributedStringValue = Awesome.Solid.globe.asAttributedText(fontSize: 16)
        }
        
        sectionTitle.stringValue = server.name
    }
    
}
