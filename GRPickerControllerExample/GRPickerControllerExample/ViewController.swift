//
//  ViewController.swift
//  GRPickerControllerExample
//
//  Created by Gaurav Parmar on 01/05/21.
//

import UIKit
import GRPickerViewController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction private func btnOpenPicker() {
        let vc = GRPickerViewController.init(type: .phoneCode)
        vc.screenTite = "Select Phone Code"
        vc.imgStyle = .corner
        vc.delegate = self
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }


}

extension ViewController : GRPickerDelegate {
    func didSelected(_ viewController: GRPickerViewController, with info: DataInfo?) {
        print(info?.country)
    }
    
    func didClose(_ viewController: GRPickerViewController) {
        
    }
}
