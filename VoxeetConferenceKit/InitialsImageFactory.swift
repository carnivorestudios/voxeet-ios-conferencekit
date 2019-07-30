//
//  InitialsImageFactory.swift
//  VoxeetConferenceKit
//
//  Created by anuraag mohanty on 7/15/19.
//  Copyright © 2019 Voxeet. All rights reserved.
//

import Foundation
import VoxeetSDK

class InitialsImageFactory: NSObject {
    
    class func imageWith(initials: String?, user: VTUser?) -> UIImage? {
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let colors:[UIColor] = ["263238".toUIColor(),
                                "004d40".toUIColor(),
                                "006064".toUIColor(),
                                "311b92".toUIColor(),
                                "263238".toUIColor(),
                                "aa00ff".toUIColor(),
                                "ff5722".toUIColor(),
                                "110b43".toUIColor(),
                                "3B34EC".toUIColor(),
                                "8834EC".toUIColor(),
                                "EC8C34".toUIColor(),
                                "6BE367".toUIColor(),
                                "CFE367".toUIColor(),
                                "E36767".toUIColor(),
                                "67AEE3".toUIColor(),
                                "E367E0".toUIColor(),
                                "34ECEB".toUIColor(),
                                "8734EC".toUIColor(),
                                "6768E3".toUIColor(),
                                "37A6B3".toUIColor(),
                                "764BA2".toUIColor(),
                                "0BA360".toUIColor(),
                                "A30B4B".toUIColor(),
                                "0B2FA3".toUIColor(),
                                "0BA1A3".toUIColor(),
                                "1D1D1D".toUIColor(),
                                "34D8EC".toUIColor(),
                                "31BB99".toUIColor(),
                                "667EEA".toUIColor(),
                                "67E3DC".toUIColor(),
                                "E36785".toUIColor(),
                                "67C9E3".toUIColor(),
                                "BBE367".toUIColor(),
                                "C5C5C5".toUIColor()]
        var total: Int = 0
        for u in (user?.name!.unicodeScalars)! {
            total += Int(UInt32(u))
        }
        let index = total % colors.count
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = colors[index]
        nameLabel.layer.borderWidth = 4
        nameLabel.layer.borderColor = UIColor.white.cgColor
        nameLabel.layer.cornerRadius = frame.size.width/2
        nameLabel.textColor = .white
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 50)
        
        nameLabel.text = initials
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
    
}
extension String {
    func toUIColor() -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
