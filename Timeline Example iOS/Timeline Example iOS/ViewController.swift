//
//  ViewController.swift
//  Timeline Example iOS
//
//  Created by James Bean on 5/2/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import UIKit
import Timeline

class ViewController: UIViewController {

    var square: UIView!
    
    let timeline = Timeline()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        square = UIView(frame: view.frame.insetBy(dx: 100, dy: 100))
        
        squareColorToRed()
        
        timeline.add(action: printSomething, identifier: "print something", at: 2)
        timeline.add(action: squareColorToGreen, identifier: "to green", at: 2)
        
        view.addSubview(square)
        
        timeline.start()
    }
    
    func printSomething() {
        print("something")
    }
    
    func squareColorToGreen() {
        DispatchQueue.main.async {
            self.square.backgroundColor = .green
        }
    }
    
    func squareColorToRed() {
        square.backgroundColor = .red
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

