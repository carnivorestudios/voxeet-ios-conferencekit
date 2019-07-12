//
//  CircleButton.swift
//  VoxeetConferenceKit
//
//  Created by anuraag mohanty on 7/12/19.
//  Copyright © 2019 Voxeet. All rights reserved.
//

import UIKit

class CircleButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    func setupButton() {
        layer.cornerRadius = CGFloat(frame.width/2)
    }

}
