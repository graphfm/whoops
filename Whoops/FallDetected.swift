//
//  FallDetected.swift
//  Whoops
//
//  Created by Anna Koczur on 27/10/2018.
//  Copyright © 2018 Anna Koczur. All rights reserved.
//

import UIKit
import MessageUI
import RealmSwift

class FallDetected: UIViewController, MFMessageComposeViewControllerDelegate {

    let realm = try! Realm()
    var phoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let phoneSetting = realm.object(ofType: Setting.self, forPrimaryKey: "emergencyNumber")
        
        if (phoneSetting != nil) {
            self.phoneNumber = phoneSetting!.value
        }
    }
    
    @IBAction func fellButOK(_ sender: Any) {
        try! realm.write() {
            realm.create(Fall.self, value: [Date()])
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didNotFall(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fellNeedsHelp(_ sender: Any) {
         try! realm.write() {
            realm.create(Fall.self, value: [Date()])
        }
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Fall was detected and help is needed!"
            controller.recipients = [self.phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            controller.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            controller.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            controller.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
