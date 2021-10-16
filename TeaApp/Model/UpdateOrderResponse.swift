//
//  updateOrderResponse.swift
//  TeaApp
//
//  Created by Alisha on 2021/10/10.
//

import Foundation
struct UpdateOrderResponse: Codable {
    let records: [UpdateOrderRecord]
}

struct UpdateOrderRecord: Codable {
    let id: String
    let fields: UpdateOrderFields
}

struct UpdateOrderFields: Codable {
    let orderer: String
    let capacity: String
    let sugarLevel: String
    let tempLevel: String
    let toppings: String?
    let quantity: Int
    let subtotal: Int
    let toppingsArrString: String
    let time: String
}
