//
//  Enums.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/22.
//

import Foundation
import UIKit

enum categoryList: String,CaseIterable {
    case season = "季節限定2"
    case cheese = "芝芝系列"
    case fruit = "果粒茶系列"
    case juice = "鮮果茶飲"
    case tea = "原味茶"
    case milkTeaColl = "濃醇系列"
    case freshMilkTea = "香醇系列"
    case special = "獨家特調"
}

enum OrderInfo: CaseIterable {
    case orderer
    case capacity
    case sugarLevel
    case tempLevel
    case toppings
}

enum Capacity: String,CaseIterable {
    case large = "大杯"
    case bottle = "瓶"
}

enum SugarLevel: String,CaseIterable {
    case normal = "正常"
    case less = "８分"
    case half = "半糖"
    case light = "３分"
    case one = "１分"
    case none = "無糖"
}

enum TempLevel: String,CaseIterable {
    case iceNormal = "正常冰"
    case iceLess = "少冰"
    case iceLight = "微冰"
    case iceFree = "去冰"
    case warm = "溫"
    case hot = "熱"
}

enum Toppings: String, CaseIterable {
    case coconutJelly = "椰果"
    case garassJelly = "仙草凍"
    case boba = "波霸"
    case pearl = "珍珠"
    case mixed = "混珠"
    case doubleQ = "雙Ｑ果"
    case honey = "蜂蜜"
    case yakult = "養樂多"
    case greenTeaJelly = "綠茶凍"
    case grapePearl = "葡萄波波"
    case cheeseCream = "芝芝"
    case creamBrulee = "布蕾"
    case iceCream = "冰淇淋"
}


enum ToppingsPrice: Int, CaseIterable {
    case coconutJelly
    case garassJelly
    case boba
    case pearl
    case mixed
    case doubleQ
    case honey
    case yakult
    case greenTeaJelly
    case grapePearl
    case cheeseCream
    case creamBrulee
    case iceCream
    
    var price: Int {
        switch self {
        case .coconutJelly:
            return 5
        case .garassJelly:
            return 5
        case .boba:
            return 10
        case .pearl:
            return 10
        case .mixed:
            return 10
        case .doubleQ:
            return 10
        case .honey:
            return 10
        case .yakult:
            return 10
        case .greenTeaJelly:
            return 10
        case .grapePearl:
            return 15
        case .cheeseCream:
            return 20
        case .creamBrulee:
            return 20
        case .iceCream:
            return 20
        }
    }
    
}

enum NetworkError: Error {
    case invalidUrl
    case requestFailed(Error)
    case invalidData
    case invalidResponse
}



extension UIColor {
    static let macuLightRed = UIColor(red: 253/255, green: 133/255, blue: 134/255, alpha: 0.5)
}


struct checkToppings {
    var title: String
    var isMarked: Bool
}
