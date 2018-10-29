//
//  StatisticsViewController.swift
//  Whoops
//
//  Created by Anna Koczur on 11.10.2018.
//  Copyright © 2018 Anna Koczur. All rights reserved.
//

import UIKit
import RealmSwift

class StatisticsViewController: UIViewController {
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var week: UILabel!
    @IBOutlet weak var today: UILabel!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavbarImage()
        
        let todayStart = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let todayEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        
        let totalFalls = realm.objects(Fall.self).count
        let weekFalls = realm.objects(Fall.self).filter("date > %@ && date < %@", todayStart.startOfWeek!, todayStart.endOfWeek!).count
        let todayFalls = realm.objects(Fall.self).filter("date > %@ && date < %@", todayStart, todayEnd).count
        
        total.text = String(totalFalls)
        week.text = String(weekFalls)
        today.text = String(todayFalls)
    }
    
    
    func addNavbarImage() {
        let navController = navigationController!
        
        let image = #imageLiteral(resourceName: "LogoY")
        
        let imageView = UIImageView(image: image)
        
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height - 15
        
        let bannerX = bannerWidth / 2 - image.size.width / 2
        let bannerY = bannerHeight / 2 - image.size.height / 2
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
        
    }

}
