//
//  LoadingViewController.swift
//  TeaApp
//
//  Created by Alisha on 2021/9/21.
//

import UIKit

class LoadingViewController: UIViewController {
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    let imageWidth = CGFloat(80)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 5, alpha: 0.8)
        
        
        let imageView = UIImageView(frame: CGRect(x: (width-imageWidth)/2, y: (width-imageWidth)/2, width: imageWidth, height: imageWidth))
        view.addSubview(imageView)
        
        guard let data = NSDataAsset(name: "drinkLoading")?.data else {
            return
        }
        
        let cfData = data as CFData
        
        CGAnimateImageDataWithBlock(cfData, nil) { (_, cgimage, _) in
            imageView.image = UIImage(cgImage: cgimage)
            
        }
        
        
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
