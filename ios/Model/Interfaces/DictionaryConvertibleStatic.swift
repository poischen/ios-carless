//
//  DictionaryConvertibleStatic.swift
//  ios
//
//  Created by Konrad Fischer on 07.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

/*
This interface is for objects that are only received from the DB and not created or edited dynamically.
 */

import Foundation

protocol DictionaryConvertibleStatic {
    init?(id: Int, dict: [String:AnyObject])
    var dict:[String:AnyObject] { get }
    var id:Int { get } // ID should be immutable
}
