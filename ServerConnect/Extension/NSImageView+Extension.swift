//
//  NSImageView+Extension.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 06/04/2024.
//

import Foundation

import Cocoa

extension NSImageView {
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = NSImage(data: data) else {
                // Handle the error (e.g., network error, invalid data, etc.)
                if let error = error {
                    print("Error fetching the image: \(error.localizedDescription)")
                } else {
                    print("Invalid data or response")
                }
                return
            }
            
            DispatchQueue.main.async {
                // Update the UI on the main thread
                self.imageScaling = .scaleProportionallyDown
                self.image = image
            }
        }
        
        task.resume() // Start the download task
    }
}
