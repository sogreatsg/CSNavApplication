//
//  IndexViewController.swift
//  demo
//
//  Created by KITTISAK SRIDET on 29/11/2562 BE.
//  Copyright © 2562 KITTISAK SRIDET. All rights reserved.
//

import UIKit


class IndexViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
         print("IndexViewController")
        // Do any additional setup after loading the view.
        if defaults.bool(forKey: "First Launch") == true {
                   
                   print("Second+")
//                   button.sendActions(for: .touchUpInside)
            // Run Code After First Launch
                   
                   defaults.set(true, forKey: "First Launch")
                   
               } else {
                   
                   
                   print("First")
                   
                   // Run Code During First Launch
                   defaults.set(true, forKey: "First Launch")
                   
               }
    }

    @IBAction func indexButton(_ sender: Any) {
          print("ButtonClicked")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
