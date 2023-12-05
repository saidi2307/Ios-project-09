//
//  Usermodel.swift
//  MusicApp
//
//  Created by Macbook-Pro on 18/11/23.
//

import Foundation

struct UserDataModel: Codable {
    let dob: String?
    let email: String?
    let name: String?
    let password: String?
    let gender: String?
}
