//
//  Datetime+BootTime.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 25/01/2022.
//

import Foundation

extension Date {
    static func uptime() -> Date? {
        var tv = timeval()
        var tvSize = MemoryLayout<timeval>.size
        let err = sysctlbyname("kern.boottime", &tv, &tvSize, nil, 0);
        guard err == 0, tvSize == MemoryLayout<timeval>.size else {
            return nil
        }
        return Date(timeIntervalSince1970: Double(tv.tv_sec) + Double(tv.tv_usec) / 1_000_000.0)
    }
}
