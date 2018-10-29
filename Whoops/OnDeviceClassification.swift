//
//  OnDeviceClassification.swift
//  Whoops
//
//  Created by Anna Koczur on 27/10/2018.
//  Copyright © 2018 Anna Koczur. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

class OnDeviceClassification {
    static let sharedInstance = OnDeviceClassification()
    let classifier = Whoops()
    let motion = CMMotionManager()
    let queue = OperationQueue()
    var timer: Timer!
    var currentWindow: [MotionData] = []
    var nextWindow: [MotionData] = []
    
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

                    let motionData = MotionData(magAcc: accMag, magGyro: gyroMag, accX: ax, accY: ay, accZ: az, gyroX: gx, gyroY: gy, gyroZ: gz)
                    self.currentWindow.append(motionData)
                    if (self.currentWindow.count > 150) {
                        self.nextWindow.append(motionData)
                    }
                    if (self.currentWindow.count == 300) {
                        self.runClassifier(window: self.currentWindow.map { $0 })
                        self.currentWindow = self.nextWindow.map { $0 }
                        self.nextWindow = []
                    }
                }
            })
        }
    }
    
    func stopCollectingMotionData() {
        self.motion.stopDeviceMotionUpdates()
    }
    
    func runClassifier(window: [MotionData]) {
        print(Date().description + " - running classifier")
        let magAccVector = window.map { $0.magAcc }
        let magGyroVector = window.map { $0.magGyro }
        let accXVector = window.map { $0.accX }
        let accYVector = window.map { $0.accY }
        let accZVector = window.map { $0.accZ }
        let gyroXVector = window.map { $0.gyroX }
        let gyroYVector = window.map { $0.gyroY }
        let gyroZVector = window.map { $0.gyroZ }
        
        let maxAccMag = magAccVector.max()
        let maxGyroMag = magGyroVector.max()
        let magCorr = pearsonCorrelation(x: magAccVector, y: magGyroVector)
        
        let accXYCorr = pearsonCorrelation(x: accXVector, y: accYVector)
        let accXZCorr = pearsonCorrelation(x: accXVector, y: accZVector)
        let accYZCorr = pearsonCorrelation(x: accYVector, y: accZVector)
        
        let gyroXYCorr = pearsonCorrelation(x: gyroXVector, y: gyroYVector)
        let gyroXZCorr = pearsonCorrelation(x: gyroXVector, y: gyroZVector)
        let gyroYZCorr = pearsonCorrelation(x: gyroYVector, y: gyroZVector)
        
        let input = WhoopsInput(max_mag_acc: maxAccMag!, max_mag_gyro: maxGyroMag!, mag_corr: magCorr, acc_x_y_corr: accXYCorr, acc_x_z_corr: accXZCorr, acc_y_z_corr: accYZCorr, gyro_x_y_corr: gyroXYCorr, gyro_x_z_corr: gyroXZCorr, gyro_y_z_corr: gyroYZCorr)
        do {
            let result = try classifier.prediction(input: input)
            if (result.label == 1) {
                DispatchQueue.main.async {
                    let vc = UIApplication.shared.keyWindow?.rootViewController
                    
                    let fallDetected = vc?.storyboard?.instantiateViewController(withIdentifier: "fallDetected")
                    vc?.present(fallDetected!, animated: true, completion: nil)
                }
                
            }
        } catch {
            
        }
    }
    
    func pearsonCorrelation(x: [Double], y: [Double]) -> Double {
        var pearsonCorrelation = 0.0
        let xAvg = (x.reduce(0.0, +)) / Double(x.count)
        let yAvg = (y.reduce(0.0, +)) / Double(y.count)
        var nominator = 0.0
        var denominatorX = 0.0
        var denominatorY = 0.0
        
        for i in 0...x.count - 1 {
            nominator += (x[i] - xAvg) * (y[i] - yAvg)
            denominatorX += pow((x[i] - xAvg), 2)
            denominatorY += pow((y[i] - yAvg), 2)
        }
        
        let denominator = sqrt(denominatorX) * sqrt(denominatorY)
        if (denominator == 0) {
            return 0.0
        }
        pearsonCorrelation = nominator / denominator
        return pearsonCorrelation
    }
}
