//
//  AniaViewController.swift
//  Whoops!
//
//  Created by Anna Koczur on 05.10.2018.
//  Copyright © 2018 Mark Radbourne. All rights reserved.
//

import UIKit
import RealmSwift

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let onDeviceClassification = OnDeviceClassification.sharedInstance
    let mqttClient = MQTTAzureClient.sharedInstance
    let pickerData = ["native", "azure"]
    let realm = try! Realm()
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var modePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavbarImage()
        
        let numberSetting = realm.object(ofType: Setting.self, forPrimaryKey: "emergencyNumber")
        let modeSetting = realm.object(ofType: Setting.self, forPrimaryKey: "mode")
        
        if (numberSetting != nil) {
            self.phoneNumber.text = numberSetting?.value
        }
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
        
        self.modePicker.delegate = self
        self.modePicker.dataSource = self
        
        if (modeSetting != nil) {
            if (modeSetting?.value == "native") {
                self.modePicker.selectRow(0, inComponent: 0, animated: false)
            } else {
                self.modePicker.selectRow(1, inComponent: 0, animated: false)
            }
        }
    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        phoneNumber.endEditing(true)
    }
    
    @IBAction func editingDidEnd(_ sender: Any) {
        try! realm.write() {
            realm.create(Setting.self, value: ["emergencyNumber", self.phoneNumber.text ?? ""], update: true)
        }
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        try! realm.write() {
            realm.create(Setting.self, value: ["mode", self.pickerData[row]], update: true)
        }
        
        if (row == 0) {
            mqttClient.stopCollectingMotionData()
            mqttClient.disconnect()
            onDeviceClassification.startCollectingMotionData()
        } else {
            onDeviceClassification.stopCollectingMotionData()
            mqttClient.connectToAzure()
            mqttClient.startCollectingMotionData()
        }
    }

}
