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
    
    var fastLabel: UILabel!
    var slowLabel: UILabel!
    
    let fastTimeline = Timeline()
    let slowTimeline = Timeline()
    
    var startButton: UIButton!
    var stopButton: UIButton!
    var pauseButton: UIButton!
    var resumeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let margin: CGFloat = 10
        let buttonHeight: CGFloat = 50
        let buttonY = view.frame.height - buttonHeight - margin
        
        startButton = UIButton(frame: CGRect(x: 10, y: buttonY, width: 100, height: 50))
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.black, for: .normal)
        startButton.addTarget(self, action: #selector(start), for: .touchDown)
        view.addSubview(startButton)
        
        stopButton = UIButton(frame: CGRect(x: 110, y: buttonY, width: 100, height: 50))
        stopButton.setTitle("Stop", for: .normal)
        stopButton.setTitleColor(.black, for: .normal)
        stopButton.addTarget(self, action: #selector(stop), for: .touchDown)
        view.addSubview(stopButton)
        
        pauseButton = UIButton(frame: CGRect(x: 220, y: buttonY, width: 100, height: 50))
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.setTitleColor(.black, for: .normal)
        pauseButton.addTarget(self, action: #selector(pause), for: .touchDown)
        view.addSubview(pauseButton)

        resumeButton = UIButton(frame: CGRect(x: 330, y: buttonY, width: 100, height: 50))
        resumeButton.setTitle("Resume", for: .normal)
        resumeButton.setTitleColor(.black, for: .normal)
        resumeButton.addTarget(self, action: #selector(resume), for: .touchDown)
        view.addSubview(resumeButton)
        
        fastLabel = UILabel(frame: view.frame.insetBy(dx: 100, dy: 200))
        fastLabel.text = ""
        fastLabel.font = UIFont(name: "Courier", size: 100)
        fastLabel.textAlignment = .center
        view.addSubview(fastLabel)
        
        slowLabel = UILabel(frame: view.frame.insetBy(dx: 100, dy: 200))
        slowLabel.layer.position.y += 100
        slowLabel.text = ""
        slowLabel.font = UIFont(name: "Courier", size: 100)
        slowLabel.textAlignment = .center
        view.addSubview(slowLabel)

        let increment = {
            self.updateSlowLabel(Int(self.slowTimeline.clock.elapsed * 1000))
        }
        
        slowTimeline.loop(
            action: increment,
            identifier: "",
            every: 1/30
        )
        
        fastTimeline.playbackRate = 1
        slowTimeline.playbackRate = 1
    }
    
    func start() {
        fastTimeline.start()
        slowTimeline.start()
    }
    
    func stop() {
        updateFastLabel(0)
        updateSlowLabel(0)
        fastTimeline.stop()
        slowTimeline.stop()
    }
    
    func pause() {
        fastTimeline.pause()
        slowTimeline.pause()
    }
    
    func resume() {
        fastTimeline.resume()
        slowTimeline.resume()
    }
    
    func updateFastLabel(_ value: Int) {
        DispatchQueue.main.async {
            self.fastLabel.text = "\(value)"
        }
    }
    
    func updateSlowLabel(_ value: Int) {
        DispatchQueue.main.async {
            self.slowLabel.text = "\(value)"
        }
    }
    
    func updateTimecodeLabel() {
        
        let elapsed = fastTimeline.clock.elapsed

        let ms = Int(elapsed.truncatingRemainder(dividingBy: 1) * 1000).formatted(digits: 3)
        let seconds = Int(elapsed.truncatingRemainder(dividingBy: 60)).formatted(digits: 2)
        let minutes = (Int(elapsed / 60) % 60).formatted(digits: 2)
        let hours = Int(elapsed / 3600).formatted(digits: 2)

        DispatchQueue.main.async {
            self.fastLabel.text = "\(hours):\(minutes):\(seconds):\(ms)"
        }
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

extension Int {
    
    /// - returns: `String` with the given amount of digits.
    public func formatted(digits: Int = 0) -> String {
        let format = "%0\(digits)ld"
        return String(format: format, self)
    }
}
