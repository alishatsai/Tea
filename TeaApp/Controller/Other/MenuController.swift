//
//  MenuController.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/26.
//

import Foundation
import UIKit

class  MenuController {
    static let shared = MenuController()
    let baseURL = URL(string: "https://api.airtable.com/v0/appCtlMy2sw2htv9o/")!
    
    // MARK: - GET MENU
    func fetchMenuRecords(_ page: String, completion: @escaping (Result<Array<MenuRecords>,Error>) -> Void) {
        let menuURL = baseURL.appendingPathComponent(page)
        guard let components = URLComponents(url: menuURL, resolvingAgainstBaseURL: true) else { return }
        guard let menuURL = components.url else { return }
        print("\(menuURL)")
        
        var request = URLRequest(url: menuURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let menuResponse = try decoder.decode(MenuResponse.self, from: data)
                    completion(.success(menuResponse.records))
                    print("Fetch Menu Success")
                } catch {
                    completion(.failure(error))
                    print("Fetch Menu Failed")
                }
            } else if let error = error {
                completion(.failure(error))
                print("Fetch Menu Failed")
            }
        }.resume()
    }
    
    // MARK: - FETCH IMAGE
    func fetchImage(urlString: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        guard let imageURL = URL(string: urlString) else {
            completion(.failure(.invalidUrl))
            return
        }
        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(.invalidData))
                return
            }
            completion(.success(image))
        }.resume()
    }
    
    
    // MARK: - GET Order
    func fetchOrderRecords(orderURL: URL, completion: @escaping (Result<Array<OrderRecords>,Error>) -> Void) {
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let orderResponse = try decoder.decode(OrderResponse.self, from: data)
//                    print("檢查fetch order")
//                    print(String(data: data, encoding: .utf8)!)
                    
                    completion(.success(orderResponse.records))
                    print("Fetch Order Success")
                } catch {
                    completion(.failure(error))
                    print("Fetch Order Failed")
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - POST Order
    func postOrder(orderData:OrderResponse, completion: @escaping (Result<String,Error>) -> Void) {
        let orderURL = baseURL.appendingPathComponent("order")
        guard let components = URLComponents(url: orderURL, resolvingAgainstBaseURL: true) else { return }
        guard let orderURL = components.url else { return }
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(orderData)

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(orderData)
//            print("檢查post")
//            print(String(data: request.httpBody!, encoding: .utf8)!)
            URLSession.shared.dataTask(with: request) { data, response, resError in
                if let data = data,
                   let content = String(data: data, encoding: .utf8) {
                    completion(.success(content))
                } else if let resError = resError {
                    completion(.failure(resError))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }

    
    // MARK: - DELETE Order
    func deleteOrder(orderID:String, completion: @escaping(Result<String,Error>) -> Void) {
        var orderURL = baseURL.appendingPathComponent("order")
        orderURL = orderURL.appendingPathComponent(orderID)
        guard let components = URLComponents(url: orderURL, resolvingAgainstBaseURL: true) else { return }
        guard let orderURL = components.url else { return }
        print("delete:\(orderURL)")
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with:request) { (data,response,resError) in
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               resError == nil,
               let data = data,
               let content = String(data:data,encoding: .utf8){
                completion(.success(content))
            }else if let resError = resError {
                completion(.failure(resError))
            }
        }.resume()

    }
    

    // MARK: - PATCH Order
    func updateOrder(orderData: UpdateOrderResponse, completion: @escaping (Result<String, Error>) -> Void) {
        let orderURL = baseURL.appendingPathComponent("order")
        guard let components = URLComponents(url: orderURL, resolvingAgainstBaseURL: true) else { return }
        guard let orderURL = components.url else { return }
        print("updateOrder's oderURL:\(orderURL)")
        var request = URLRequest(url: orderURL)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(orderData)
            print("檢查patch")
            print(String(data: request.httpBody!, encoding: .utf8)!)
            URLSession.shared.dataTask(with: request) { data, response, resError in
                if let data = data,
                   let content = String(data: data, encoding: .utf8) {
                    completion(.success(content))
                } else if let resError = resError {
                    completion(.failure(resError))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
}


//轉換無價格顯示方式
public func priceIsZeroFormate(price: Int) -> String {
    if price == 0{
        return "-"
    }else{
        return "\(price)"
    }
}

