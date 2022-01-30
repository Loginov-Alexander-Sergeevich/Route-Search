//
//  Extension + UIViewController.swift
//  RouteSearch
//
//  Created by Александр Александров on 27.01.2022.
//

import Foundation
import UIKit

extension UIViewController {
    
    func addAdressAlert(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { action in
            
            let textField = alertController.textFields?.first
            
            guard let text = textField?.text else { return }
            
            completionHandler(text)
            
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default)
        
        alertController.addTextField { textField in
            textField.placeholder = placeholder
        }
        
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func errorAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertOk = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(alertOk)
        
        present(alertController, animated: true, completion: nil)
    }
}
