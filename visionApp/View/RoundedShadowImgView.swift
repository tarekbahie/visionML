//
//  RoundedShadowImgView.swift
//  visionApp
//
//  Created by tarek bahie on 1/1/19.
//  Copyright © 2019 tarek bahie. All rights reserved.
//

import UIKit

@IBDesignable class RoundedShadowImgView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        createShadowBtn()
    }
    override func prepareForInterfaceBuilder() {
        createShadowBtn()
    }
    func createShadowBtn(){
        self.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.layer.shadowRadius = 15.0
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 15
    }

}
