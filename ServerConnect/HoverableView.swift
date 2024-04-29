//
//  HoverableView.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 12/12/2021.
//

import Cocoa

extension NSView {
    func setTextColorForAllChildren(color: NSColor) {
            self.subviews.forEach { subview in
                // If the subview is an NSTextField, set its text color.
                if let textField = subview as? NSTextField {
                    textField.textColor = color
                }
                // No need for an 'is NSView' check here, as all subviews are NSView instances.
                // Simply proceed to call the method recursively.
                // This ensures that the method applies to subviews of subviews and so on.
                else {
                    subview.setTextColorForAllChildren(color: color)
                }
            }
        }
}

class HoverableView: NSView {

    var mouseInside : Bool = false { didSet {
           needsDisplay = true
       }}
        
    var trackingArea : NSTrackingArea?
    
    override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            
            if mouseInside {
                NSColor.controlAccentColor.setFill()
                bounds.fill()
                layer?.cornerRadius = 10
                self.setTextColorForAllChildren(color: .white)
              
            } else {
                self.setTextColorForAllChildren(color: .textColor)
            }
    
        }
    
    
    override func updateTrackingAreas() {
           super.updateTrackingAreas()
           
           ensureTrackingArea()
           
           if let trackingArea = trackingArea, !trackingAreas.contains(trackingArea) {
               addTrackingArea(trackingArea)
           }
       }
       
       func ensureTrackingArea() {
           if trackingArea == nil {
               trackingArea = NSTrackingArea(rect: .zero,
                                             options: [
                                               .inVisibleRect,
                                               .activeAlways,
                                               .mouseEnteredAndExited],
                                             owner: self,
                                             userInfo: nil)
           }
       }
       
       override func mouseEntered(with event: NSEvent) {
           mouseInside = true
       }
       
       override func mouseExited(with event: NSEvent) {
           mouseInside = false
       }
}
