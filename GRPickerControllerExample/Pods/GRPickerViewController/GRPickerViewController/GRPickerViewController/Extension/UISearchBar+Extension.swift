//
//  UISearchBar+Extension.swift
//  GRPickerViewController
//
//  Created by Gaurav Parmar on 01/05/21.
//

import Foundation
import UIKit

extension UISearchBar {
    
    var textField: UITextField? {
        return value(forKey: "searchField") as? UITextField
    }
    
    func setSearchIcon(image: UIImage) {
        setImage(image, for: .search, state: .normal)
    }
    
    func setClearIcon(image: UIImage) {
        setImage(image, for: .clear, state: .normal)
    }
}
