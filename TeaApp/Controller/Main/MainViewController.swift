//
//  MainViewController.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/7.
//

import UIKit

public let apiKey = "keyu9qrLz08BWYdZe"


class MainViewController: UIViewController {

    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var categoryBtn: [UIButton]!
    @IBOutlet weak var categoryScrollView: UIScrollView!
    @IBOutlet weak var menuScrollView: UIScrollView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    
    //banner image array
    let bannerImgArr: [UIImage] =
        {
            var images = [UIImage]()
            for i in 1...6
            {
                let image = UIImage(named: "p\(i)")
                images.append(image!)
            }
            return images
        }()
    
    var timer: Timer?
    var currentBannerCellIndex = 0
    
    var orderList = Array<OrderRecords>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderCollectionView.dataSource = self
        sliderCollectionView.delegate = self
        
        pageControl.numberOfPages = bannerImgArr.count
        
        startTimer()
        //設定初啟動畫面,飲料分類一是紅色標題
        categoryBtn.forEach { UIButton in
            UIButton.setTitleColor(.gray, for: .normal)
        }
        categoryBtn[0].setTitleColor(.red, for: .normal)
        
        loading.hidesWhenStopped = true
        loading.startAnimating()
        loading.backgroundColor = .red
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        fetchOrder()
    }

    
    func fetchOrder() {
        // 若直接appendingPathComponenet("order?sort[][field]=time")會抓取訂單失敗
        var url = MenuController.shared.baseURL.appendingPathComponent("order")
        url = URL(string:"\(url)?sort[][field]=time")!
        print("\(url)")
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
            if let items = self.tabBarController?.tabBar.items as NSArray? {
                let tabItem = items.object(at: 1) as! UITabBarItem
                tabItem.badgeValue = "\(orderList.count)"
                print("訂單數量：\(orderList.count)")
                
            }
            self.loading.stopAnimating()
        }
        
    }

    
    func displayError(_ error: Error, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // banner 切換速度
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(moveToNextIndex), userInfo: nil, repeats: true)
    }
    
    @objc func moveToNextIndex() {
        if currentBannerCellIndex < bannerImgArr.count - 1 {
            currentBannerCellIndex += 1
        }else {
            currentBannerCellIndex = 0
        }
        
        sliderCollectionView.scrollToItem(at: IndexPath(item: currentBannerCellIndex, section: 0), at: .centeredHorizontally, animated: true)
        pageControl.currentPage = currentBannerCellIndex
       
    }

    
    @IBAction func changeCategoryBtns(_ sender: UIButton) {
        let width = menuScrollView.bounds.width
        let x = CGFloat(sender.tag) * width
        let offset = CGPoint(x: x, y: 0)
        menuScrollView.setContentOffset(offset, animated: true)

        //設定分類按鈕是灰體字
        categoryBtn.forEach { sender in
            sender.setTitleColor(.gray, for: .normal)
        }
        //點選分類按鈕變紅字
        let currentIndex = Int(offset.x/width)
        if currentIndex == sender.tag {
            categoryBtn[sender.tag].setTitleColor(.red, for: .normal)
        }
    }
    
    
}

//BannerCollectionViewCell
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerImgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = sliderCollectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath) as? BannerCollectionViewCell else { return UICollectionViewCell() }
        cell.bannerImageView.image = bannerImgArr[indexPath.row]
        cell.bannerImageView.contentMode = .scaleToFill
        return cell
    }

}
//BannerCollectionViewCell Layout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: sliderCollectionView.frame.width, height: sliderCollectionView.frame.height)
    }
    //設定照片間距為０
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}


