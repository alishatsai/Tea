//
//  menuResponse.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/4.
//

import Foundation

struct MenuResponse: Codable {
    let records: [MenuRecords]
}

struct MenuRecords: Codable {
    let id: String
    let fields: MenuFields
}

struct MenuFields: Codable {
    let drinkName: String
    let largePrice: Int?
    let bottlePrice: Int?
    let reminder: String?
    let coldOnly: String?
    let category: String
    let drinkImage: [MenuDrinkImage]
    struct MenuDrinkImage: Codable {
        let url: String
    }
}



