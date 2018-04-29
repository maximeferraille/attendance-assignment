//
//  LoginViewController.swift
//  attendance-assignment
//
//  Created by Maxime Ferraille on 26/04/2018.
//  Copyright © 2018 Maxime Ferraille. All rights reserved.
//

import UIKit
import FontAwesome_swift

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var error: UILabel!
    var animator : UIDynamicAnimator!
    var snap : UISnapBehavior!
    @IBOutlet weak var formContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: self.view)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        email.font = UIFont.fontAwesome(ofSize: 14)
        email.placeholder = String.fontAwesomeIcon(code: "fa-envelope")
        pass.font = UIFont.fontAwesome(ofSize: 20)
        pass.placeholder = String.fontAwesomeIcon(code: "fa-key")
        pass.isSecureTextEntry = true
        error.textColor = UIColor.red
        self.view.backgroundColor = UIColor.MainColor.Purple.mainPurple
        
    }
    
    @IBAction func login(_ sender: Any) {
        var userEmail  = email.text
        var userPass = pass.text
        if (userEmail ?? "").isEmpty || (userPass ?? "").isEmpty{
            error.text = "Veuillez remplir tous les champs du formulaire."
           var point =  CGPoint(x: self.view.center.x, y: CGFloat(self.view.center.y - 120))
        snapBehaviorsToPoint(point: point)
            return;
        }

        let parameters = ["email": userEmail, "password": userPass]
        let url = URL(string: "www.thisismylink.com/postName.php")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    let token = json["token"] as? String
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.userToken = token
                }
            } catch let error {
                print(error.localizedDescription)
                self.error.text = "Identifiants invalides."
            }
        })
        task.resume()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.userToken = "MON SUPER TOKEEEEEEN"
        print(appDelegate.userToken)
        var point =  CGPoint(x: self.view.center.x, y: CGFloat(self.view.center.y - 350))
        snapBehaviorsToPoint(point: point)
    }
    
    func snapBehaviorsToPoint(point:CGPoint){
        if snap != nil {
            animator?.removeBehavior(snap)
        }
        snap = UISnapBehavior(item: error, snapTo: point)
        snap.damping = 1
        animator?.addBehavior(snap)
    }
}

