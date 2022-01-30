//
//  Extension + UIView.swift
//  RouteSearch
//
//  Created by Александр Александров on 27.01.2022.
//

import Foundation
import UIKit

extension UIView {
    
    func addSubViews(views: [UIView]) {
        for item in views {
            addSubview(item)
        }
    }
}
