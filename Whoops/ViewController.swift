// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

import UIKit
import AzureIoTHubClient
import Foundation
import CoreMotion


class ViewController: UIViewController {
    
    //Put you connection string here
    private let connectionString = "HostName=Whoops-IoT-Hub.azure-devices.net;DeviceId=iosApp;SharedAccessKey=JTUEX99no8j8oNcVT9C3ol4UlJ0/A8HyaIF6ByaRSZ8="

    // Select your protocol of choice: MQTT_Protocol, AMQP_Protocol or HTTP_Protocol
    // Note: HTTP_Protocol is not currently supported
    private let iotProtocol: IOTHUB_CLIENT_TRANSPORT_PROVIDER = MQTT_Protocol
    
    // IoT hub handle
    private var iotHubClientHandle: IOTHUB_CLIENT_LL_HANDLE!;
    let motion = CMMotionManager()
    let queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    /// Increments the messages sent count and updates the UI
    func incrementSent() {
        cntSent += 1
//        lblSent.text = String(cntSent)
    }
    
    /// Sends a message to the IoT hub
    @objc func sendMessage(motionData: String) {
        
        // Construct the message
        let messageHandle: IOTHUB_MESSAGE_HANDLE = IoTHubMessage_CreateFromByteArray(motionData, motionData.utf8.count)
        
        if (messageHandle != OpaquePointer.init(bitPattern: 0)) {
            
            // Manipulate my self pointer so that the callback can access the class instance
            let that = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            
            if (IOTHUB_CLIENT_OK == IoTHubClient_LL_SendEventAsync(iotHubClientHandle, messageHandle, mySendConfirmationCallback, that)) {
                incrementSent()
//                print("Success!")
            }
        }
        
        //
         IoTHubClient_LL_DoWork(iotHubClientHandle)
    }
    
    /// Check for waiting messages and send any that have been buffered
    @objc func dowork() {
        IoTHubClient_LL_DoWork(iotHubClientHandle)
    }
    
    // This function will be called when a message confirmation is received
    //
    // This is a variable that contains a function which causes the code to be out of the class instance's
    // scope. In order to interact with the UI class instance address is passed in userContext. It is
    // somewhat of a machination to convert the UnsafeMutableRawPointer back to a class instance
    let mySendConfirmationCallback: IOTHUB_CLIENT_EVENT_CONFIRMATION_CALLBACK = { result, userContext in
        
        var mySelf: ViewController = Unmanaged<ViewController>.fromOpaque(userContext!).takeUnretainedValue()
        
        if (result == IOTHUB_CLIENT_CONFIRMATION_OK) {
//            print("OK")
        }
        else {
            print("NOT OK")
        }
    }
    
    // This function is called when a message is received from the IoT hub. Once again it has to get a
    // pointer to the class instance as in the function above.
    let myReceiveMessageCallback: IOTHUB_CLIENT_MESSAGE_CALLBACK_ASYNC = { message, userContext in
        
        var mySelf: ViewController = Unmanaged<ViewController>.fromOpaque(userContext!).takeUnretainedValue()
        
        var messageId: String!
        var correlationId: String!
        var size: Int = 0
        var buff: UnsafePointer<UInt8>?
        var messageString: String = ""
        
        messageId = String(describing: IoTHubMessage_GetMessageId(message))
        correlationId = String(describing: IoTHubMessage_GetCorrelationId(message))
        
        if (messageId == nil) {
            messageId = "<nil>"
        }
        
        if correlationId == nil {
            correlationId = "<nil>"
        }
        
        // Get the data from the message
        var rc: IOTHUB_MESSAGE_RESULT = IoTHubMessage_GetByteArray(message, &buff, &size)
        
        if rc == IOTHUB_MESSAGE_OK {
            // Print data in hex
            for i in 0 ..< size {
                let out = String(buff![i], radix: 16)
                print("0x" + out, terminator: " ")
            }
            
            print()
            
            // This assumes the received message is a string
            let data = Data(bytes: buff!, count: size)
            messageString = String.init(data: data, encoding: String.Encoding.utf8)!
            
            print("Message Id:", messageId, " Correlation Id:", correlationId)
            print("Message:", messageString)
        }
        else {
            print("Failed to acquire message data")
        }
        return IOTHUBMESSAGE_ACCEPTED
    }
    
    func startCollectingMotionData() {
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 200.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical,
                                                 to: self.queue, withHandler: { (data, error) in
                                                    // Make sure the data is valid before accessing it.
                                                    if let validData = data {
                                                        // Get the attitude relative to the magnetic north reference frame.
                                                        let gx = validData.rotationRate.x
                                                        let gy = validData.rotationRate.y
                                                        let gz = validData.rotationRate.z
                                                        let ax = validData.gravity.x
                                                        let ay = validData.gravity.y
                                                        let az = validData.gravity.z
                                                        let gyroMag = sqrt(pow(gx, 2) + pow(gy, 2) + pow(gz, 2))
                                                        let accMag = sqrt(pow(ax, 2) + pow(ay, 2) + pow(az, 2))
                                                        
                                                        let data = String(format:"{\"mag_acc\": %f, \"mag_gyro\": %f, \"acc_x\": %f, \"acc_y\": %f, \"acc_z\": %f, \"gyro_x\": %f, \"gyro_y\": %f, \"gyro_z\": %f,  }", accMag, gyroMag, ax, ay, az, gx, gy, gz)
                                            
                                                            
//                                                            ["mag_acc":String(accMag),
//                                                            "mag_gyro": String(gyroMag),
//                                                            "acc_x": String(ax),
//                                                            "acc_y": String(ay),
//                                                            "acc_z": String(az),
//                                                            "gyro_x": String(gx),
//                                                            "gyro_y": String(gy),
//                                                            "gyro_z": String(gz)
//                                                        ]
//                                                        print(data)
                                                        
                                                        self.sendMessage(motionData: data)
                                                        
                                                        // Use the motion data in your app.
                                                    }
            })
        }
    }
    
    /// Called when the start button is clicked on the UI. Starts sending messages.
    ///
    /// - parameter sender: The clicked button
    @IBAction func start(_ sender: UIButton) {
        
        // Dialog box to show action received
        cntSent = 0
        lblSent.text = String(cntSent)
        
        // Create the client handle
        iotHubClientHandle = IoTHubClient_LL_CreateFromConnectionString(connectionString, iotProtocol)
        
        if (iotHubClientHandle == nil) {
            print("Failed to create IoT handle")
            
            return
        }
        
        // Mangle my self pointer in order to pass it as an UnsafeMutableRawPointer
        let that = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // Set up the message callback
        if (IOTHUB_CLIENT_OK != (IoTHubClient_LL_SetMessageCallback(iotHubClientHandle, myReceiveMessageCallback, that))) {
            print("Failed to establish received message callback")
            
            return
        }
        
        startCollectingMotionData()
    }
    
    /// Called when the stop button is clicked on the UI. Stops sending messages and cleans up.
    ///
    /// - parameter sender: The clicked button
    @IBAction func stop(_ sender: UIButton) {
        timerMsgRate?.invalidate()
        timerDoWork?.invalidate()
        IoTHubClient_LL_Destroy(iotHubClientHandle)
        self.motion.stopDeviceMotionUpdates()
    }
    
//    func addNavbarImage() {
//        let navController = navigationController!
//
//        let image = #imageLiteral(resourceName: "outline_directions_run_black_24dp.png")
//
//        let imageView = UIImageView(image: image)
//
//        let bannerWidth = navController.navigationBar.frame.size.width
//        let bannerHeight = navController.navigationBar.frame.size.height
//
//        let bannerX = bannerWidth / 2 - image.size.width / 2
//        let bannerY = bannerHeight / 2 - image.size.height / 2
//
//        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
//        imageView.contentMode = .scaleAspectFit
//
//        navigationItem.titleView = imageView
//
//    }
}

