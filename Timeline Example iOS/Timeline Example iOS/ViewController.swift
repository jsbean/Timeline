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

    var playbackRateSlider: UISlider!
    
    var timeline = Timeline()
    
    var beatViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateBeatViews()
        
        self.view.backgroundColor = .black

        let meters = MetricalStructure(meters: (0..<100).map { _ in Meter(4,4) })
        
        let onDownbeat: (Meter, Int, Tempo) -> () = { _ in
            
            let beatView = self.beatViews[0]
            
            DispatchQueue.main.async {
                beatView.backgroundColor = .white
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    beatView.backgroundColor = .black
                }
            }
        }
        
        let onUpbeat: (Meter, Int, Tempo) -> () = { _ , beat, _ in
            
            let beatView = self.beatViews[beat - 1]
            
            DispatchQueue.main.async {
                beatView.backgroundColor = .darkGray
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    beatView.backgroundColor = .black
                }
            }
        }
        
        let metronomeController = MetronomeController(
            structure: meters,
            tempo: Tempo(60),
            onDownbeat: onDownbeat,
            onUpbeat: onUpbeat
        )
        
        metronomeController.actionByOffset.forEach { offset, action in
            timeline.add(action: action, identifier: "metronome", at: offset)
        }
        
        timeline.playbackRate = 1
        timeline.start()

//        let margin: CGFloat = 10
//        let buttonHeight: CGFloat = 50
//        let buttonY = view.frame.height - buttonHeight - margin
//        
//        startButton = UIButton(frame: CGRect(x: 10, y: buttonY, width: 100, height: 50))
//        startButton.setTitle("Start", for: .normal)
//        startButton.setTitleColor(.black, for: .normal)
//        startButton.addTarget(self, action: #selector(start), for: .touchDown)
//        view.addSubview(startButton)
//        
//        stopButton = UIButton(frame: CGRect(x: 110, y: buttonY, width: 100, height: 50))
//        stopButton.setTitle("Stop", for: .normal)
//        stopButton.setTitleColor(.black, for: .normal)
//        stopButton.addTarget(self, action: #selector(stop), for: .touchDown)
//        view.addSubview(stopButton)
//        
//        pauseButton = UIButton(frame: CGRect(x: 220, y: buttonY, width: 100, height: 50))
//        pauseButton.setTitle("Pause", for: .normal)
//        pauseButton.setTitleColor(.black, for: .normal)
//        pauseButton.addTarget(self, action: #selector(pause), for: .touchDown)
//        view.addSubview(pauseButton)
//
//        resumeButton = UIButton(frame: CGRect(x: 330, y: buttonY, width: 100, height: 50))
//        resumeButton.setTitle("Resume", for: .normal)
//        resumeButton.setTitleColor(.black, for: .normal)
//        resumeButton.addTarget(self, action: #selector(resume), for: .touchDown)
//        view.addSubview(resumeButton)
//        
//        fastLabel = UILabel(frame: view.frame.insetBy(dx: 100, dy: 200))
//        fastLabel.text = ""
//        fastLabel.font = UIFont(name: "Courier", size: 100)
//        fastLabel.textAlignment = .center
//        view.addSubview(fastLabel)
//        
//        slowLabel = UILabel(frame: view.frame.insetBy(dx: 100, dy: 200))
//        slowLabel.layer.position.y += 100
//        slowLabel.text = ""
//        slowLabel.font = UIFont(name: "Courier", size: 100)
//        slowLabel.textAlignment = .center
//        view.addSubview(slowLabel)
//
//        let increment = {
//            self.updateSlowLabel(Int(self.slowTimeline.clock.elapsed * 1000))
//        }
//        
//        slowTimeline.loop(
//            action: increment,
//            identifier: "",
//            every: 1/30
//        )
//        
//        fastTimeline.playbackRate = 1
//        slowTimeline.playbackRate = 1
    }
    
    func generateBeatViews() {

        let width = view.frame.width
        let margin: CGFloat = 50
        let useable = width - 2 * margin
        let deltaX = useable / 3
        
        let size = CGSize(width: 100, height: 100)
        
        let y = view.frame.midY - 0.5 * size.height
        
        for x in 0..<4 {
            let view = UIView(frame:
                CGRect(
                    origin: CGPoint(x: margin + (CGFloat(x) * deltaX - 0.5 * size.width), y: y), size: size))
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.borderWidth = 1
            view.backgroundColor = .black
            beatViews.append(view)
            self.view.addSubview(view)
        }
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
