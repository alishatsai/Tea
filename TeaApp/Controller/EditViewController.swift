//
//  EditViewController.swift
//  TeaApp
//
//  Created by Alisha on 2021/9/26.
//

import UIKit

class EditViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var editTableView: UITableView!
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var addToCartBtn: UIButton!
    @IBOutlet weak var drinkStatusLabel: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    

    // 接收Order資料
    let orderList: Array<OrderRecords>
    let indexPath: Int
    var orderer: String
    var imageUrl: String
    var drinkName: String
    var capacity: String
    var tempLevel: String
    var sugarLevel: String
    var toppings: String?
    var countNum: Int
    var subtotal: Int
    var time: String
    var largePrice: Int
    var bottlePrice: Int
    var reminder: String?
    var coldOnly: String?
    var category: String
    var toppingsArrString: String
    var orderID: String
    var createdTime: String
    init?(coder: NSCoder,orderList: Array<OrderRecords>,orderID:String, indexPath: Int){
        self.orderList = orderList
        self.indexPath = indexPath
        self.orderer = orderList[indexPath].fields.orderer
        self.imageUrl = orderList[indexPath].fields.imageUrl
        self.drinkName = orderList[indexPath].fields.drinkName
        self.capacity = orderList[indexPath].fields.capacity
        self.tempLevel = orderList[indexPath].fields.tempLevel
        self.sugarLevel = orderList[indexPath].fields.sugarLevel
        self.toppings = orderList[indexPath].fields.toppings ?? ""
        self.countNum = orderList[indexPath].fields.quantity
        self.subtotal = orderList[indexPath].fields.subtotal
        self.time = orderList[indexPath].fields.time
        self.largePrice = orderList[indexPath].fields.largePrice
        self.bottlePrice = orderList[indexPath].fields.bottlePrice
        self.reminder = orderList[indexPath].fields.reminder ?? ""
        self.coldOnly = orderList[indexPath].fields.coldOnly ?? ""
        self.category = orderList[indexPath].fields.category
        self.toppings = orderList[indexPath].fields.toppings ?? ""
        self.toppingsArrString = orderList[indexPath].fields.toppingsArrString
        self.orderID = orderList[indexPath].id ?? ""
        self.createdTime = orderList[indexPath].createdTime!
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var editTime: String?
    var newOrderPrice: Int?
    var drinkPrice = 0
    var toppingsPrice = 0
    var toppingsChecked = Array(repeating: false, count: Toppings.allCases.count)
    var toppingsArr = Array(repeating: "", count: Toppings.allCases.count)
    var delegate: TotalViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loading.color = .red
        loading.startAnimating()
        loading.hidesWhenStopped = true
        
        editTableView.delegate = self
        editTableView.dataSource = self
        editTableView.allowsSelection = true
        editTableView.allowsMultipleSelection = false
        
        fetchImage()
        drinkNameLabel.text = "\(orderList[indexPath].fields.drinkName)"
        quantityLabel.text = "\(orderList[indexPath].fields.quantity)"
        if capacity == "大杯" {
            drinkPrice = orderList[indexPath].fields.largePrice
        }else {
            drinkPrice = orderList[indexPath].fields.bottlePrice
        }
        toppingsPrice = subtotal/countNum - drinkPrice
        
        initToppings()
        updateDrinkStatusLabel()
        createdTimeFormatter()
        updateSubtotalLabel()
    }

    func initToppings() {
        //將toppingsArrString轉成string array
        toppingsArr = toppingsArrString.components(separatedBy: ",")
        
        //將toppingsArr中"false"改成空字串,
        //ture的情況下將toppingsChecked改成true,toppingsArr改成相對的toppings品項名稱
        for i in 0...Toppings.allCases.count-1 {
            if toppingsArr[i] == "false" {
                toppingsArr[i] = ""
            }
            if toppingsArr[i] == "true" {
                toppingsChecked[i] = true
                toppingsArr[i] = Toppings.allCases[i].rawValue
            }
        }
        
    }
    
    
    func createdTimeFormatter() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        editTime = formatter.string(from: now)
        print("Edit time: \(editTime!)")
    }
    
    func updateDrinkStatusLabel() {
        if toppings == "" {
            drinkStatusLabel.text = "\(capacity),\(sugarLevel),\(tempLevel)"
        }else {
            drinkStatusLabel.text = "\(capacity),\(sugarLevel),\(tempLevel),\(toppings!)"
        }
  
    }
    
    func updateSubtotalLabel(){
        newOrderPrice = drinkPrice + toppingsPrice
        subtotalLabel.text = "$ \(newOrderPrice! * countNum)"
        
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
        
        orderer = textField.text!
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
        
        let updateOrderField = UpdateOrderFields(orderer: orderer, capacity: capacity, sugarLevel: sugarLevel, tempLevel: tempLevel, toppings: toppings, quantity: countNum, subtotal: newOrderPrice!*countNum, toppingsArrString: toppingsArrString, time: editTime!)
        
        let updateOrderRecord = UpdateOrderRecord(id: orderID, fields: updateOrderField)
        
        let updateOrderResponse = UpdateOrderResponse(records: [updateOrderRecord])
        
        if updateOrderField.orderer == "" {
            self.showAlert(title: "Oops!", message: "記得填上您的大名喔！")
        }else {

            MenuController.shared.updateOrder(orderData: updateOrderResponse) { result in
                switch result {
                case .success(let content):
                    print("update success:\(content)")
                    
                    if content.contains("records") {
                        print("I found records")
                        
                        DispatchQueue.main.async {
                            self.showAlert(title: "Thank You!", message: "修改成功！")
                        }
                    }else {
                        print("I can't find records")
                        DispatchQueue.main.async {
                            self.showAlert(title: "Oops!", message: "修改訂單失敗！")
                        }
                    }
                case .failure(let error):
                    print("update failure:\(error)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Oops!", message: "修改訂單失敗！")
                    }
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.dismiss(animated: true) {
                // dismiss之後回到前一畫面，藉由delegate更新訂單
                self.delegate?.fetchOrder()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)  
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

extension EditViewController: UITableViewDelegate,UITableViewDataSource {
    
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
            guard let cell = editTableView.dequeueReusableCell(withIdentifier: "\(OrdererTableViewCell.self)") as? OrdererTableViewCell else { return UITableViewCell() }
            cell.ordererTextField.delegate = self
            cell.ordererTextField.text = orderer
//            print("原本訂購人：\(orderer)")
            return cell
        case .capacity:
            guard let cell = editTableView.dequeueReusableCell(withIdentifier: "\(CapacityTableViewCell.self)", for: indexPath) as? CapacityTableViewCell else { return UITableViewCell() }
//            print("drinkName:\(String(describing: drinkName)) category:\(String(describing: category))")

            cell.delegate = self
            
            cell.capacitySegmentedControl.selectedSegmentIndex = -1
            
            switch capacity {
            case "\(Capacity.large.rawValue)":
                cell.capacitySegmentedControl.selectedSegmentIndex = 0
            case "\(Capacity.bottle.rawValue)":
                cell.capacitySegmentedControl.selectedSegmentIndex = 1
            default:
                break
            }
            cell.capacitySegmentedControl.selectedSegmentTintColor = .macuLightRed
            if bottlePrice == 0 {
                cell.capacitySegmentedControl.removeSegment(at: 1, animated: false)

                cell.capacitySegmentedControl.setTitle("\(Capacity.large.rawValue)", forSegmentAt: 0)
                self.capacity = cell.capacitySegmentedControl.titleForSegment(at: cell.capacitySegmentedControl.selectedSegmentIndex)!

            }else {
                cell.capacitySegmentedControl.setTitle("\(Capacity.large.rawValue)", forSegmentAt: 0)
                cell.capacitySegmentedControl.setTitle("\(Capacity.bottle.rawValue)", forSegmentAt: 1)
                self.capacity = cell.capacitySegmentedControl.titleForSegment(at: cell.capacitySegmentedControl.selectedSegmentIndex)!
            }

            return cell

        case .sugarLevel:
            guard let cell = editTableView.dequeueReusableCell(withIdentifier: "\(SugarTableViewCell.self)", for: indexPath) as? SugarTableViewCell else { return UITableViewCell() }
            cell.delegate = self
            cell.sugarSegmentedControl.selectedSegmentIndex = -1

            
            switch sugarLevel {
            case "\(SugarLevel.normal.rawValue)甜":
                cell.sugarSegmentedControl.selectedSegmentIndex = 0
            case "\(SugarLevel.less.rawValue)甜":
                cell.sugarSegmentedControl.selectedSegmentIndex = 1
            case SugarLevel.half.rawValue:
                cell.sugarSegmentedControl.selectedSegmentIndex = 2
            case "\(SugarLevel.light.rawValue)甜":
                cell.sugarSegmentedControl.selectedSegmentIndex = 3
            case "\(SugarLevel.one.rawValue)甜":
                cell.sugarSegmentedControl.selectedSegmentIndex = 4
            case SugarLevel.none.rawValue:
                cell.sugarSegmentedControl.selectedSegmentIndex = 5
            default:
                break
            }
            
           
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
            guard let cell = editTableView.dequeueReusableCell(withIdentifier: "\(TempTableViewCell.self)", for: indexPath) as? TempTableViewCell else { return UITableViewCell() }
            cell.delegate = self
            
            
            cell.tempSegmentedControl.selectedSegmentIndex = -1
            
            switch tempLevel {
            case "\(TempLevel.iceNormal.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 0
            case "\(TempLevel.iceLess.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 1
            case "\(TempLevel.iceLight.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 2
            case "\(TempLevel.iceFree.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 3
            case "\(TempLevel.warm.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 4
            case "\(TempLevel.hot.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 5
            default:
                break
            }
            
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
            guard let cell = editTableView.dequeueReusableCell(withIdentifier: "\(ToppingsTableViewCell.self)", for: indexPath) as? ToppingsTableViewCell else { return UITableViewCell() }
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
            
//            print("toppingsArr:\(toppingsArr)")

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



extension EditViewController: CapacityTableViewCellDelegate {
 
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

extension EditViewController: SugarTableViewCellDelegate {
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

extension EditViewController: TempTableViewCellDelegate {
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
