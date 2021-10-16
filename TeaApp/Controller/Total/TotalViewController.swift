//
//  TotalViewController.swift
//  TeaApp
//
//  Created by Alisha on 2021/9/18.
//

import UIKit

class TotalViewController: UIViewController {
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var totalTableView: UITableView!

    @IBOutlet weak var loading: UIActivityIndicatorView!
    

    var orderList = Array<OrderRecords>()
    
    var order: OrderResponse?
    
    var orderID = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.color = .red
        loading.startAnimating()
        loading.hidesWhenStopped = true
        
        totalTableView.dataSource = self
        totalTableView.delegate = self
            
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        fetchOrder()
 
    }

    func fetchOrder() {
        // 若直接appendingPathComponenet("order?sort[][field]=time")會抓取訂單失敗
        var url = MenuController.shared.baseURL.appendingPathComponent("order")
        url = URL(string:"\(url)?sort[][field]=time")!
        MenuController.shared.fetchOrderRecords(orderURL: url) { (result) in
            switch result {
            case .success(let orderLists):
                self.updateUI(with: orderLists)
                     
            case .failure(let error):
                self.displayError(error, title: "Failed to Fetch Order")
                
            }
        }
    }
    
    func updateUI(with orderList: Array<OrderRecords>) {
        DispatchQueue.main.async {
            self.orderList = orderList
            self.loading.stopAnimating()
            self.initTabItem()
            self.initTotal()
            self.totalTableView.reloadData()
        }
    }

    func initTabItem() {
        if let items = self.tabBarController?.tabBar.items as NSArray? {
            let tabItem = items.object(at: 1) as! UITabBarItem
            tabItem.badgeValue = "\(orderList.count)"
        }
    }
    
    
    func initTotal() {
        var count = 0
        self.orderList.forEach { orderList in
            count += orderList.fields.quantity
        }
        self.countLabel.text = "共\(count)杯"
        
        var total = 0
        self.orderList.forEach { orderList in
            total += orderList.fields.subtotal
        }
        self.totalLabel.text = "\(total)元"
    }
    
    
    func displayError(_ error: Error, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    @IBSegueAction func showEditOrder(_ coder: NSCoder) -> EditViewController? {
        guard let row = totalTableView.indexPathsForSelectedRows?.first?.row else {return nil}
        let vc = EditViewController(coder: coder, orderList: orderList, orderID: orderID, indexPath: row)
        vc?.delegate = self
        return vc
    }


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TotalViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.orderList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        180
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as? TotalTableViewCell else { return UITableViewCell() }
        
        let orderField = self.orderList[indexPath.row].fields
        cell.ordererNameLabel.text = orderField.orderer
        cell.drinkNameLabel.text = orderField.drinkName
        cell.capacityLabel.text = orderField.capacity
        cell.sugarLevelLabel.text = orderField.sugarLevel
        cell.tempLevelLabel.text = orderField.tempLevel
        cell.toppingsLabel.text = "加料：\(orderField.toppings ?? "無")"
        cell.quantityLabel.text = "\(orderField.quantity)杯"
        cell.subtotalLabel.text = "\(orderField.subtotal)元"
        
        //抓圖片
        let imageUrl = orderField.imageUrl
        MenuController.shared.fetchImage(urlString: imageUrl) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    cell.drinkImageView.image = image
                }
            case .failure(let networkError):
            switch networkError {
            case .invalidUrl:
                print(networkError)
            case .requestFailed(let error):
                print(networkError, error)
            case .invalidData:
                print(networkError)
            case .invalidResponse:
                print(networkError)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let order = self.orderList[indexPath.row]

            let alertController = UIAlertController(title: "\(order.fields.orderer):\(order.fields.drinkName)", message: "確定刪除此筆訂單嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                self.loading.startAnimating()
                
                MenuController.shared.deleteOrder(orderID: order.id!) { result in
                    switch result {
                    case .success(let content):
                        print("DeleteOrder success:\(content)")
                        self.orderList.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            self.totalTableView.deleteRows(at: [indexPath], with: .fade)
                            self.initTotal()
                            self.initTabItem()
                            self.totalTableView.reloadData()
                            self.loading.stopAnimating()
                        }
                        
                    case .failure(let error):
                        print("DeleteOrder failed:\(error)")
                    }
                }

            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}
