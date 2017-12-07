//
//  DictionaryConvertible.swift
//  ios
//
//  Created by Konrad Fischer on 07.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

protocol DictionaryConvertible {
    associatedtype convertTo
    static func dictionaryToArray(dictionary: NSDictionary)->[convertTo]
}
