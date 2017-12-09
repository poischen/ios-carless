//
//  DictionaryConvertible.swift
//  ios
//
//  Created by Konrad Fischer on 07.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

protocol DictionaryConvertible {
    init?(id: Int, dict: [String:AnyObject])
    var dict:[String:AnyObject] { get }
}
