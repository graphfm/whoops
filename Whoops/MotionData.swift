//
//  MotionData.swift
//  Whoops
//
//  Created by Anna Koczur on 27/10/2018.
//  Copyright © 2018 Anna Koczur. All rights reserved.
//

import Foundation

class MotionData {
    var magAcc: Double
    var magGyro: Double
    var accX: Double
    var accY: Double
    var accZ: Double
    var gyroX: Double
    var gyroY: Double
    var gyroZ: Double
    
    init(magAcc: Double, magGyro: Double, accX: Double, accY: Double, accZ: Double, gyroX: Double, gyroY: Double, gyroZ: Double) {
        self.magAcc = magAcc
        self.magGyro = magGyro
        self.accX = accX
        self.accY = accY
        self.accZ = accZ
        self.gyroX = gyroX
        self.gyroY = gyroY
        self.gyroZ = gyroZ
    }
}
