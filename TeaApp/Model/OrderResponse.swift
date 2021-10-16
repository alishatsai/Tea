//
//  orderResponse.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/4.
//

import Foundation

struct OrderResponse: Codable {
    let records: [OrderRecords]
}

struct OrderRecords: Codable {
    var id: String?
    var fields: OrderFields
    var createdTime: String?
    init(id:String? = nil,fields:OrderFields,createdTime:String? = nil) {
        self.id = id
        self.fields = fields
        self.createdTime = createdTime
    }
}

struct OrderFields: Codable {
    var orderer: String
    var imageUrl: String
    var drinkName: String
    var capacity: String
    var sugarLevel: String
    var tempLevel: String
    var toppings: String?
    var quantity: Int
    var subtotal: Int
    var time: String
    
    //為了編輯頁面能記憶原訂單內容
    let largePrice: Int
    let bottlePrice: Int
    let reminder: String?
    let coldOnly: String?
    let category: String
    var toppingsArrString: String
   
}



