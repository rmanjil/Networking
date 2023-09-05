//
//  ViewController.swift
//  Networking
//
//  Created by manjil on 30/03/2023.
//

import UIKit
struct None: Decodable {
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            _ = try? await Networking.default.dataRequest(router: UserRouter.home, type: None.self)
        }
    }


}

