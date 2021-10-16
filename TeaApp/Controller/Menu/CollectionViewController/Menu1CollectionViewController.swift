//
//  Menu1CollectionViewController.swift
//  TeaApp
//
//  Created by Alisha on 2021/8/9.
//

import UIKit

private let reuseIdentifier = "Cell"


class Menu1CollectionViewController: UICollectionViewController {
    

    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var menuRecords = Array<MenuRecords>()

    let page = "menu1"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        loading.color = .red
        loading.startAnimating()
        loading.hidesWhenStopped = true
        
        MenuController.shared.fetchMenuRecords(page) { result in
            switch result {
            case .success(let menuRecord):
                self.updateUI(with: menuRecord)
            case .failure(let error):
                self.displayError(error, title: "Failed to Fetch Menu1 Items")
            }
        }
        
        configureCellSize()
        
    }
    
    func configureCellSize() {
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let width = UIScreen.main.bounds.width/2.2
        flowLayout?.itemSize = CGSize(width: width, height: width*1.2)
        flowLayout?.estimatedItemSize = .zero
        flowLayout?.minimumLineSpacing = 1 // 滑動方向為「垂直」的話即「上下」的間距;滑動方向為「平行」則為「左右」的間距
        flowLayout?.minimumInteritemSpacing = 30 //滑動方向為「垂直」的話即「左右」的間距;滑動方向為「平行」則為「上下」的間距
        flowLayout?.scrollDirection = UICollectionView.ScrollDirection.vertical
    }
    
    
    func updateUI(with drinkItem: [MenuRecords]) {
        DispatchQueue.main.async {
            self.menuRecords = drinkItem
            self.collectionView.reloadData()
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
    
    @IBSegueAction func showDrinkDetail(_ coder: NSCoder) -> OrderViewController? {
        guard let item = collectionView.indexPathsForSelectedItems?.first?.item else { return nil }
        return OrderViewController.init(coder: coder, menuItem: menuRecords, indexPath: item)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return menuRecords.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? Menu1CollectionViewCell else {return UICollectionViewCell()}
        let menuRecord = menuRecords[indexPath.item]
        cell.menu1DrinkNameLabel.text = menuRecord.fields.drinkName
        cell.menu1DrinkLargePriceLabel.text = priceIsZeroFormate(price: menuRecord.fields.largePrice!)
        cell.menu1DrinkBottlePriceLabel.text = priceIsZeroFormate(price: menuRecord.fields.bottlePrice!)
        cell.menu1ReminderLabel.text = menuRecord.fields.reminder

        //抓圖片
        let imageUrl = menuRecord.fields.drinkImage.first?.url
        MenuController.shared.fetchImage(urlString: imageUrl!) { result in
            switch result {
            case .success(let image):
                
                DispatchQueue.main.async {
                    cell.menu1DrinkImageView.image = image
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
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
