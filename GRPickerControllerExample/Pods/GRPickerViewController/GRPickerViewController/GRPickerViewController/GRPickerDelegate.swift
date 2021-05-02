//
//  GRPickerDelegate.swift
//  Example
//
//  Created by Gaurav Parmar on 02/05/21.
//

import UIKit

public protocol GRPickerDelegate {
    func didSelected(_ viewController : GRPickerViewController,with info : DataInfo?)
    func didClose(_ viewController : GRPickerViewController)
}

