//
//  buttonTitleLabel.swift
//  VoxeetConferenceKit
//
//  Created by anuraag mohanty on 7/29/19.
//  Copyright © 2019 Voxeet. All rights reserved.
//

import UIKit

class buttonTitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        font = UIFont(name: "Poppins-SemiBold", size: self.font.pointSize)
    }

}
