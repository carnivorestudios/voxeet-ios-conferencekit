//
//  NetworkStatus.swift
//  ClanHQ
//
//  Created by vThink on 28/05/19.
//  Copyright © 2019 Carnivore. All rights reserved.
//

import SystemConfiguration
import Foundation

class NetworkStatus: NSObject {
    static let shared = NetworkStatus()
    @objc dynamic var isReachable: Bool = false
    fileprivate var timer: Timer?
    
    func startListener() {
        stopListener()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.reachableCheck()
        })
    }
    
    func stopListener() {
        timer?.invalidate()
    }
    
    fileprivate func reachableCheck() {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            if self.isReachable {
                self.isReachable = false
            }
            return
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        if self.isReachable == false && ret == true {
            self.isReachable = true
        } else if self.isReachable == true && ret == false {
            self.isReachable = false
        }
    }
}
