//
//  String+Extension.swift
//  MisoConnect
//
//  Created by Emil Møller Lind on 31/03/2019.
//  Copyright © 2019 Noque ApS. All rights reserved.
//

import Foundation

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: unreserved)
        return self.addingPercentEncoding(withAllowedCharacters: allowed)
    }
}
