//
//  SignalLevel.swift
//  Plugin
//
//  Created by NUS15268-11-nicassa on 1/24/22.
//  Copyright © 2022 Max Lynch. All rights reserved.
//

import Foundation

public enum SignalLevel: Int {
    case noBars
    case oneBar
    case twoBars
    case threeBars
    case fourBars
    case fiveBars

    public init(rssi: Double) {
        switch rssi {
            case ...(-80): self = .noBars
            case ...(-70): self = .oneBar
            case ...(-60): self = .twoBars
            case ...(-50): self = .threeBars
            case ...(-40): self = .fourBars
            default:       self = .fiveBars
        }
    }

    public init(rssi: Int) {
        self.init(rssi: Double(rssi))
    }

    public var dots: Int { rawValue }

    public static let maxBars = 5
}
