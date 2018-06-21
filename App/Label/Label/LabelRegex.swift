//
//  LabelRegex.swift
//  Label
//
//  Created by Anthony Gordon on 09/12/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//

import Foundation

// MARK: REGEX
/**
 Returns a regex for the property, this is currently used in the order confirmation screen.
 */
struct labelRegex {
    let name = Regex("^[a-zA-Z][0-9a-zA-Z .,'-]*$")
    let email = Regex("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
    let address = Regex("(?:[A-Z0-9][a-z0-9,.-]+[ ]?)+")
    let city = Regex("(?:[A-Z][a-z.-]+[ ]?)+")
    let postcode = labelCore().regexPostcode
    let password: Regex! = labelCore().regexPassword
}
