//
//  UINavigationController+LoadConfiguration.swift
//  ApplozicSwift
//
//  Created by Rewardz on 23/11/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import UIKit

extension UINavigationController{
    func loadConfigurations(_ configuration : ALKConfiguration) {
        self.navigationBar.barTintColor = configuration.navigationBarBackgroundColor
        self.navigationBar.tintColor = configuration.navigationBarItemColor
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : configuration.navigationTitleColor]
        self.navigationBar.isTranslucent = false
        if configuration.hideNavigationBarBottomLine {
            self.navigationBar.hideBottomHairline()}
    }
}
