//
//  TimeInterval+Time.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 25/01/2022.
//

import Foundation

extension TimeInterval {
    private var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }

    private var seconds: Int {
        return Int(self) % 60
    }

    var minutes: Int {
        return (Int(self) / 60 ) % 60
    }

    var hours: Int {
        return Int(self) / 3600
    }
    
    var days: Int {
        return self.hours / 24
    }

    var stringTime: String {
        if days != 0 {
            return "\(days)d."
        } else if hours != 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes != 0 {
            return "\(minutes)m \(seconds)s"
        } else if milliseconds != 0 {
            return "\(seconds)s \(milliseconds)ms"
        } else {
            return "\(seconds)s"
        }
    }
}
