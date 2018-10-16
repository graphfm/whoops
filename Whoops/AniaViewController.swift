//
//  AniaViewController.swift
//  Whoops!
//
//  Created by Anna Koczur on 05.10.2018.
//  Copyright © 2018 Mark Radbourne. All rights reserved.
//

import UIKit

class AniaViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addNavbarImage()
        // Do any additional setup after loading the view.
    }
    
    func addNavbarImage() {
        let navController = navigationController!
        
        let image = #imageLiteral(resourceName: "LogoY")
        
        let imageView = UIImageView(image: image)
        
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        
        let bannerX = bannerWidth / 2 - image.size.width / 2
        let bannerY = bannerHeight / 2 - image.size.height / 2
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
        
    }

}
