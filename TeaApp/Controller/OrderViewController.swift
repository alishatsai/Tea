//
//  OrderViewController.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/22.
//

import UIKit

class OrderViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var addToCartBtn: UIButton!
    @IBOutlet weak var drinkStatusLabel: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    
    
    // 接收Menu資料
    let menuItem: Array<MenuRecords>
    let indexPath: Int
    let largePrice: Int
    let bottlePrice: Int
    let drinkName: String
    let category: String
    let coldOnly: String
    let reminder: String
    var imageUrl: String
    init?(coder: NSCoder, menuItem: Array<MenuRecords>, indexPath: Int){
        self.menuItem = menuItem
        self.indexPath = indexPath
        self.largePrice = menuItem[indexPath].fields.largePrice ?? 0
        self.bottlePrice = menuItem[indexPath].fields.bottlePrice ?? 0
        self.drinkName = menuItem[indexPath].fields.drinkName
        self.category = menuItem[indexPath].fields.category
        self.coldOnly = menuItem[indexPath].fields.coldOnly ?? ""
        self.reminder = menuItem[indexPath].fields.reminder ?? ""
        self.imageUrl = menuItem[indexPath].fields.drinkImage.first?.url ?? ""
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var orderID: String?
    var newOrderer: String?
    var capacity: String?
    var tempLevel: String?
    var sugarLevel: String?
    var toppings: String?
    var time: String?

    var countNum = 1
    var orderPrice: Int?
    var drinkPrice = 0
    var toppingsPrice = 0
    var toppingsChecked = Array(repeating: false, count: Toppings.allCases.count)
    var toppingsArr = Array(repeating: "", count: Toppings.allCases.count)
    var toppingsArrString = String(repeating: "false,", count: Toppings.allCases.count)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.color = .red
        loading.startAnimating()
        loading.hidesWhenStopped = true
        
        orderTableView.delegate = self
        orderTableView.dataSource = self
        orderTableView.allowsSelection = true
        orderTableView.allowsMultipleSelection = false

        // 把最後一個逗號去掉
        toppingsArrString.remove(at: toppingsArrString.index(before: toppingsArrString.endIndex))
//        print("initial toppingsString:\(toppingsArrString)")

        drinkNameLabel.text = menuItem[indexPath].fields.drinkName
        drinkPrice = menuItem[indexPath].fields.largePrice!
        quantityLabel.text = "\(countNum)"
        capacity = Capacity.large.rawValue
        sugarLevel = "\(SugarLevel.normal.rawValue)甜"
        tempLevel = TempLevel.iceNormal.rawValue
        toppings = ""
        
        fetchImage()
        createdTimeFormatter()
        updateSubtotalLabel()

    }

    func createdTimeFormatter() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        time = formatter.string(from: now)
        print("Created Time: \(time!)")
    }
    
    func updateDrinkStatusLabel() {
        if toppings == "" {
            drinkStatusLabel.text = "\(capacity!),\(sugarLevel!),\(tempLevel!)"
        }else {
            drinkStatusLabel.text = "\(capacity!),\(sugarLevel!),\(tempLevel!),\(toppings!)"
        }
  
    }
    
    func updateSubtotalLabel(){
        orderPrice = drinkPrice + toppingsPrice
        subtotalLabel.text = "$ \(orderPrice! * countNum)"
        
    }
    
    func fetchImage() {
        MenuController.shared.fetchImage(urlString: imageUrl) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.drinkImageView.image = image
                    self.loading.stopAnimating()
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
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        newOrderer = textField.text
        return true
    }
    
    
    @IBAction func minusBtn(_ sender: UIButton) {
        if countNum > 1 {
            countNum -= 1
        } else {
            countNum = 1
        }
        quantityLabel.text = "\(countNum)"
        
        updateSubtotalLabel()
    }
    
    @IBAction func addBtn(_ sender: UIButton) {
        if countNum < 99 {
            countNum += 1
            quantityLabel.text = "\(countNum)"
        
            updateSubtotalLabel()
        }
    }
    
    @IBAction func addToCart(_ sender: UIButton) {

        let orderField = OrderFields(orderer: newOrderer ?? "", imageUrl: imageUrl, drinkName: drinkName, capacity: capacity ?? "", sugarLevel: sugarLevel ?? "", tempLevel: tempLevel ?? "", toppings: toppings ?? "" ,quantity: countNum, subtotal: orderPrice!*countNum, time: time ?? "", largePrice: largePrice , bottlePrice: bottlePrice, reminder: reminder, coldOnly: coldOnly, category: category, toppingsArrString: toppingsArrString)
        
        // id和createdTime是airtable自動產生的,所以不用上傳
        let orderRecord = OrderRecords(id: nil, fields: orderField, createdTime: nil)

        let orderResponse = OrderResponse(records: [orderRecord])
        
        if orderField.orderer == "" {
            self.showAlert(title: "Oops!", message: "記得填上您的大名喔！")
        }else {
            MenuController.shared.postOrder(orderData: orderResponse) { result in
                switch result {
                    
                case .success(let content):
                    print("postOrder sucess:\(content)")
                    
                    
                    DispatchQueue.main.async {
                        self.showAlert(title: "Thank You!", message: "訂購成功！")

                    }
                case .failure(let error):
                    print("postOrder failure:\(error)")
                    
                    DispatchQueue.main.async {
                        self.showAlert(title: "Oops!", message: "上傳訂單失敗！")
                    }
                }
            }
        }
        
        
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in

            self.dismiss(animated: true, completion: nil)

        }))

        self.present(alert, animated: true, completion: nil)

    }
    
    
    

}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        OrderInfo.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let orderInfoType = OrderInfo.allCases[section]
        switch orderInfoType {
        case .orderer:
            return "訂購人"
        case .capacity:
            return "容量"
        case .sugarLevel:
            return "糖量"
        case .tempLevel:
            return "溫度"
        case .toppings:
            return "添加口感"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let orderInfoType = OrderInfo.allCases[section]
        switch orderInfoType {
        case .orderer,.capacity,.sugarLevel,.tempLevel:
            return 1
        case .toppings:
            return Toppings.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let orderInfoType = OrderInfo.allCases[indexPath.section]
        
        switch orderInfoType {
        case .orderer:
            guard let cell = orderTableView.dequeueReusableCell(withIdentifier: "\(OrdererTableViewCell.self)") as? OrdererTableViewCell else { return UITableViewCell() }
            cell.ordererTextField.delegate = self
            cell.ordererTextField.placeholder = "請輸入您的大名"
            guard let orderName = newOrderer else { return cell }
            cell.ordererTextField.text = orderName
            print("訂購人：\(newOrderer!)")
            return cell
        case .capacity:
            guard let cell = orderTableView.dequeueReusableCell(withIdentifier: "\(CapacityTableViewCell.self)", for: indexPath) as? CapacityTableViewCell else { return UITableViewCell() }
//            print("drinkName:\(String(describing: drinkName)) category:\(String(describing: category))")

            cell.delegate = self
            cell.capacitySegmentedControl.selectedSegmentTintColor = .macuLightRed
            if bottlePrice == 0 {
                cell.capacitySegmentedControl.removeSegment(at: 1, animated: false)
                
                cell.capacitySegmentedControl.setTitle("\(Capacity.large.rawValue)", forSegmentAt: 0)
                self.capacity = cell.capacitySegmentedControl.titleForSegment(at: cell.capacitySegmentedControl.selectedSegmentIndex)
                
            }else {
                cell.capacitySegmentedControl.setTitle("\(Capacity.large.rawValue)", forSegmentAt: 0)
                cell.capacitySegmentedControl.setTitle("\(Capacity.bottle.rawValue)", forSegmentAt: 1)
                self.capacity = cell.capacitySegmentedControl.titleForSegment(at: cell.capacitySegmentedControl.selectedSegmentIndex)
            }

            return cell
        
        case .sugarLevel:
            guard let cell = orderTableView.dequeueReusableCell(withIdentifier: "\(SugarTableViewCell.self)", for: indexPath) as? SugarTableViewCell else { return UITableViewCell() }
            cell.delegate = self
            cell.sugarSegmentedControl.selectedSegmentTintColor = .macuLightRed
            
            if drinkName == "梅子冰茶" || category == "\(categoryList.season.rawValue)" {
                cell.sugarSegmentedControl.setTitle("甜度固定", forSegmentAt: 0)
                cell.sugarSegmentedControl.selectedSegmentTintColor = .macuLightRed

                for i in 1...5 {
                    cell.sugarSegmentedControl.setWidth(0.1, forSegmentAt: i)
                    cell.sugarSegmentedControl.setEnabled(false, forSegmentAt: i)
                    
                }
                
            }
            else {
                cell.sugarSegmentedControl.setTitle("\(SugarLevel.normal.rawValue)", forSegmentAt: 0)
                cell.sugarSegmentedControl.setTitle("\(SugarLevel.less.rawValue)", forSegmentAt: 1)
                cell.sugarSegmentedControl.setTitle("\(SugarLevel.half.rawValue)", forSegmentAt: 2)
                cell.sugarSegmentedControl.setTitle("\(SugarLevel.light.rawValue)", forSegmentAt: 3)
                cell.sugarSegmentedControl.setTitle("\(SugarLevel.one.rawValue)", forSegmentAt: 4)
                cell.sugarSegmentedControl.setTitle("\(SugarLevel.none.rawValue)", forSegmentAt: 5)
                
            }
            updateDrinkStatusLabel()
            return cell

        case .tempLevel:
            guard let cell = orderTableView.dequeueReusableCell(withIdentifier: "\(TempTableViewCell.self)", for: indexPath) as? TempTableViewCell else { return UITableViewCell() }
            cell.delegate = self
            cell.tempSegmentedControl.selectedSegmentTintColor = .macuLightRed
            if coldOnly == "true"{
                cell.tempSegmentedControl.setTitle("\(TempLevel.iceNormal.rawValue)", forSegmentAt: 0)
                cell.tempSegmentedControl.setTitle("\(TempLevel.iceLess.rawValue)", forSegmentAt: 1)
                cell.tempSegmentedControl.setTitle("\(TempLevel.iceLight.rawValue)", forSegmentAt: 2)
                cell.tempSegmentedControl.setTitle("\(TempLevel.iceFree.rawValue)", forSegmentAt: 3)
                for i in 4...5 {
                    cell.tempSegmentedControl.setWidth(0.1, forSegmentAt: i)
                    cell.tempSegmentedControl.setEnabled(false, forSegmentAt: i)
                }

            }else{
                cell.tempSegmentedControl.setTitle("\(TempLevel.iceNormal.rawValue)", forSegmentAt: 0)
                cell.tempSegmentedControl.setTitle("\(TempLevel.iceLess.rawValue)", forSegmentAt: 1)
                cell.tempSegmentedControl.setTitle("\(TempLevel.iceLight.rawValue)", forSegmentAt: 2)
                cell.tempSegmentedControl.setTitle("\(TempLevel.iceFree.rawValue)", forSegmentAt: 3)
                cell.tempSegmentedControl.setTitle("\(TempLevel.warm.rawValue)", forSegmentAt: 4)
                cell.tempSegmentedControl.setTitle("\(TempLevel.hot.rawValue)", forSegmentAt: 5)
                
            }
            
            return cell
            
        case .toppings:
            guard let cell = orderTableView.dequeueReusableCell(withIdentifier: "\(ToppingsTableViewCell.self)", for: indexPath) as? ToppingsTableViewCell else { return UITableViewCell() }
            cell.toppingsNameLabel.text = Toppings.allCases[indexPath.row].rawValue
            cell.toppingsPriceLabel.text = "\(ToppingsPrice.allCases[indexPath.row].price)"
            cell.addToppingsBtn.frame.size.height = 15
            
            if toppingsChecked[indexPath.row] {
                cell.addToppingsBtn.setImage(UIImage(named: "circleCheckMark"), for: .normal)
                cell.backgroundColor = .macuLightRed

            } else {
                cell.addToppingsBtn.setImage(UIImage(named: "circle"), for: .normal)
                cell.backgroundColor = .none
            }
            
            return cell
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let orderInfoType = OrderInfo.allCases[indexPath.section]
        
        switch orderInfoType {
        
        case .orderer:
            return
        case .capacity:
            return
        case .sugarLevel:
            return
        case .tempLevel:
            return
        case .toppings:
            toppingsChecked[indexPath.row] = !toppingsChecked[indexPath.row]
//            print("\(Toppings.allCases[indexPath.row].rawValue):\(toppingsChecked[indexPath.row])")
            
            if toppingsChecked[indexPath.row] {
                toppingsPrice += ToppingsPrice.allCases[indexPath.row].price
                toppingsArr[indexPath.row] = Toppings.allCases[indexPath.row].rawValue
                
                //將string array轉成string，以利上傳至airtable
                let toppingsTrue = toppingsArr.filter { $0 != "" }
                let stringToppingsTrue = toppingsTrue.joined(separator: ",")
//                print("toppingsChecked:\(toppingsChecked)")
//                print("stringToppingsTrue:\(stringToppingsTrue)")
                toppings = stringToppingsTrue
            
                //將toppingsChecked從bool array 轉變成string array
                let result = toppingsChecked.map{$0 == true ? "true":"false"}
                
                //將string array轉成string，以利上傳至airtable
                let resultString = result.filter{$0 != ""}
                //將目前得到的toppings string結果派給原先的var toppingsArrString
                toppingsArrString = resultString.joined(separator: ",")
//                print("toppingsArrString:\(toppingsArrString)")

            } else {
                toppingsPrice -= ToppingsPrice.allCases[indexPath.row].price
                toppingsArr[indexPath.row] = ""
                
                //將string array轉成string，以利上傳至airtable
                let toppingsTrue = toppingsArr.filter { $0 != "" }
                let stringToppingsTrue = toppingsTrue.joined(separator: ",")
//                print("stringToppingsTrue:\(stringToppingsTrue)")
                toppings = stringToppingsTrue
                
                //將toppingsChecked從bool array 轉變成string array
                let result = toppingsChecked.map{$0 == true ? "true":"false"}
                
                //將string array轉成string，以利上傳至airtable
                let resultString = result.filter{$0 != ""}
                toppingsArrString = resultString.joined(separator: ",")
//                print("toppingsArrString:\(toppingsArrString)")
            }
            print("Toppings:\(toppingsArr)")
            updateDrinkStatusLabel()
            updateSubtotalLabel()
            
        }
        tableView.reloadData()
    }
}

extension OrderViewController: CapacityTableViewCellDelegate {
 
    //切換segmented control 改變drinkPrice & capacity
    func toggleCapacitySegmentedCtrl(with index: Int) {
        print("toggleCapacitySegmentedCtrl")
        switch index
        {
        case 0:
            drinkPrice = largePrice
            capacity = "\(Capacity.large.rawValue)"
            
        case 1:
            drinkPrice = bottlePrice
            capacity = "\(Capacity.bottle.rawValue)"

        default:
            break
        }
        updateSubtotalLabel()
        updateDrinkStatusLabel()
        
    }
 
}

extension OrderViewController: SugarTableViewCellDelegate {
    func toggleSugarSegmentedCtrl(with index: Int) {
        print("toggleSugarSegmentedCtrl")
        switch index{
        case 0:
            sugarLevel = "\(SugarLevel.normal.rawValue)甜"

        case 1:
            sugarLevel = "\(SugarLevel.less.rawValue)甜"

        case 2:
            sugarLevel = SugarLevel.half.rawValue //半糖

        case 3:
            sugarLevel = "\(SugarLevel.light.rawValue)甜"

        case 4:
            sugarLevel = "\(SugarLevel.one.rawValue)甜"

        case 5:
            sugarLevel = SugarLevel.none.rawValue //無糖
 
        default:
            break
        }
        updateDrinkStatusLabel()
    }


}

extension OrderViewController: TempTableViewCellDelegate {
    func toggleTempSegmentedCtrl(with index: Int) {
        print("toggleTempSegmentedCtrl")
        
        switch index {
        case 0:
            tempLevel = TempLevel.iceNormal.rawValue
        case 1:
            tempLevel = TempLevel.iceLess.rawValue
        case 2:
            tempLevel = TempLevel.iceLight.rawValue
        case 3:
            tempLevel = TempLevel.iceFree.rawValue
        case 4:
            tempLevel = TempLevel.warm.rawValue
        case 5:
            tempLevel = TempLevel.hot.rawValue
        default:
            break
        }
        updateDrinkStatusLabel()
    }
    
    
}




