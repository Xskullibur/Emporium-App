//
//  Plist.swift
//  Emporium
//
//  Created by Peh Zi Heng on 13/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

class Plist {
    /**
        Read a plist file and returns a Dictionary with the content of the plist.
     */
    static func readPlist(_ fileURL: URL) -> [String: Any]? {
        guard fileURL.pathExtension == "plist", let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        guard let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }
        print(result)
        return result
    }
}
