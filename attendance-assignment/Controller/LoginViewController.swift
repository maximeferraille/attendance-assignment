//
//  LoginViewController.swift
//  attendance-assignment
//
//  Created by Maxime Ferraille on 26/04/2018.
//  Copyright © 2018 Maxime Ferraille. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var error: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        email.placeholder = "Email"
        pass.placeholder = "Password"
        pass.isSecureTextEntry = true
    }
    
    @IBAction func login(_ sender: Any) {
        var userEmail = email.text
        var userPass = pass.text
        if (userEmail ?? "").isEmpty || (userPass ?? "").isEmpty{
            error.text = "Veuillez remplir tous les champs du formulaire."
            error.isHidden = true
        }
    }
}

