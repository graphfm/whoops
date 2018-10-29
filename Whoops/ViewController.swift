// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

import UIKit
import AzureIoTHubClient
import Foundation
import CoreMotion
import RealmSwift


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavbarImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // UI elements
    @IBOutlet weak var lblSent: UILabel!
    
    var cntSent = 0
    var cntGood: Int = 0
    var cntBad = 0
    var cntRcvd = 0
    var randomTelem : String!
    
    // Timers used to control message and polling rates
    var timerMsgRate: Timer!
    var timerDoWork: Timer!
    /// Called when the start button is clicked on the UI. Starts sending messages.
    ///
    /// - parameter sender: The clicked button
    @IBAction func start(_ sender: UIButton) {
//        onDeviceClassification.startCollectingMotionData()
    }
    
    /// Called when the stop button is clicked on the UI. Stops sending messages and cleans up.
    ///
    /// - parameter sender: The clicked button
    @IBAction func stop(_ sender: UIButton) {
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

