//
//  MQTTAzureClient.swift
//  Whoops
//
//  Created by Anna Koczur on 13.10.2018.
//  Copyright © 2018 Anna Koczur. All rights reserved.
//

import Foundation
import CoreMotion
import AzureIoTHubClient
import UIKit

class MQTTAzureClient {
    static let sharedInstance = MQTTAzureClient()
    var timer: Timer!
    //Put you connection string here
    private let connectionString = "HostName=WhoopsIoTHubSecond.azure-devices.net;DeviceId=iosApp;SharedAccessKey=tVs45A8WyPKXUpI0KHAok2t6YbheGiID9Ox0Bi7UQK4="
    
    // Select your protocol of choice: MQTT_Protocol, AMQP_Protocol or HTTP_Protocol
    // Note: HTTP_Protocol is not currently supported
    private let iotProtocol: IOTHUB_CLIENT_TRANSPORT_PROVIDER = MQTT_Protocol
    
    // IoT hub handle
    private var iotHubClientHandle: IOTHUB_CLIENT_LL_HANDLE!;
    let motion = CMMotionManager()
    let queue = OperationQueue()
    
    func connectToAzure() {
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
    }
    
    func stopCollectingMotionData() {
        self.motion.stopDeviceMotionUpdates()
        timer.invalidate()
    }
    
    func disconnect() {
        IoTHubClient_LL_Destroy(iotHubClientHandle)
    }
    
    /// Sends a message to the IoT hub
    @objc func sendMessage(motionData: String) {
        
        // Construct the message
        let messageHandle: IOTHUB_MESSAGE_HANDLE = IoTHubMessage_CreateFromByteArray(motionData, motionData.utf8.count)
        
        if (messageHandle != OpaquePointer.init(bitPattern: 0)) {
            
            // Manipulate my self pointer so that the callback can access the class instance
            let that = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            
            if (IOTHUB_CLIENT_OK == IoTHubClient_LL_SendEventAsync(iotHubClientHandle, messageHandle, mySendConfirmationCallback, that)) {
//                print("Success!")
            }
        }
    }
    
    /// Check for waiting messages and send any that have been buffered
    @objc func dowork() {
        print("Dowork")
        IoTHubClient_LL_DoWork(iotHubClientHandle)
    }
    
    // This function will be called when a message confirmation is received
    //
    // This is a variable that contains a function which causes the code to be out of the class instance's
    // scope. In order to interact with the UI class instance address is passed in userContext. It is
    // somewhat of a machination to convert the UnsafeMutableRawPointer back to a class instance
    let mySendConfirmationCallback: IOTHUB_CLIENT_EVENT_CONFIRMATION_CALLBACK = { result, userContext in
        
        var mySelf: ViewController = Unmanaged<ViewController>.fromOpaque(userContext!).takeUnretainedValue()
        print(IOTHUB_CLIENT_CONFIRMATION_OK)
        if (result == IOTHUB_CLIENT_CONFIRMATION_OK) {
                        print("OK")
        }
        else {
            print("NOT OK")
        }
    }
    
    // This function is called when a message is received from the IoT hub. Once again it has to get a
    // pointer to the class instance as in the function above.
    let myReceiveMessageCallback: IOTHUB_CLIENT_MESSAGE_CALLBACK_ASYNC = { message, userContext in
        
        
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
            
            DispatchQueue.main.async {
                let vc = UIApplication.shared.keyWindow?.rootViewController
                
                let fallDetected = vc?.storyboard?.instantiateViewController(withIdentifier: "fallDetected")
                vc?.present(fallDetected!, animated: true, completion: nil)
            }
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
            self.motion.deviceMotionUpdateInterval = 1.0 / 100.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(to: self.queue, withHandler: { (data, error) in
                                                    if let validData = data {
                                                        let gx = validData.rotationRate.x
                                                        let gy = validData.rotationRate.y
                                                        let gz = validData.rotationRate.z
                                                        let ax = validData.gravity.x + validData.userAcceleration.x
                                                        let ay = validData.gravity.y + validData.userAcceleration.y
                                                        let az = validData.gravity.z + validData.userAcceleration.z
                                                        let gyroMag = sqrt(pow(gx, 2) + pow(gy, 2) + pow(gz, 2))
                                                        let accMag = sqrt(pow(ax, 2) + pow(ay, 2) + pow(az, 2))
                                                        
                                                        let data = String(format:"{\"device_id\": \"iosApp\",\"mag_acc\": %f, \"mag_gyro\": %f, \"acc_x\": %f, \"acc_y\": %f, \"acc_z\": %f, \"gyro_x\": %f, \"gyro_y\": %f, \"gyro_z\": %f }", accMag, gyroMag, ax, ay, az, gx, gy, gz)
//                                                        print(data)
                                                            self.sendMessage(motionData: data)
                                                    }
            
            })
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dowork), userInfo: nil, repeats: true)
        }
    }
}
