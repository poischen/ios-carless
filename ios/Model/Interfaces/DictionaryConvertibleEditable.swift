//
//  DictionaryConvertible.swift
//  ios
//
//  Created by Konrad Fischer on 07.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

/*
 This interface is for objects that can be received from the DB but also edited and/or created dynamically
 */

import Foundation

protocol DictionaryConvertibleEditable {
    // the ID can be filled later, e.g. when the object is passed to StorageAPI which gets a UID from the DB, sets it in the object and then saves it to the DB
    // TODO: remove ID from constructor?
    // TODO: add contraint that ID should be editable
    init?(id: String?, dict: [String:AnyObject])
    var dict:[String:AnyObject] { get }
}
