//
//  TabBarViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/12/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class TabBarViewController: UITabBarController {
    
    var queue = [Exercise]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //Google Sign-in
        Auth.auth().addStateDidChangeListener() {
            [weak self] (auth, user) in
            guard let this = self else { return }
            if user == nil {
                this.performSegue(withIdentifier: "Show Login", sender: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
