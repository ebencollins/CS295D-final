//
//  RecordingViewController.swift
//  Conversation Analysis
//
//  Created by devon on 2/18/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recorder : AVAudioRecorder!
    var playSound : AVAudioPlayer!
    var audioPlayer : AVAudioPlayer!
    
    var recordNum = 0
    var timer = Timer()
    var isRecording = false
    var counter = 0.0
    
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBAction func record(_ sender: Any) {
        // check that we are not already recording
        if recorder == nil {
            print("startTimer")
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
            
            let filename = getURL().appendingPathComponent("\(recordNum).wave")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            do {
                recorder = try AVAudioRecorder(url: filename, settings: settings)
                recorder.delegate = self
                recorder.record()
                button.setTitle("Stop Recording?", for: .normal)
                playButton.isEnabled = false
                
            } catch {
                let alert = UIAlertController(title: "Oops!", message: "Something went wrong!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
            
        } else {
            //stop recording
            recorder.stop()
            button.setTitle("", for: .normal)
            playButton.isEnabled = true
            recorder = nil
            
            timer.invalidate()
            counter = 0.0
                        
        }
        
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        let path = getURL().appendingPathComponent("\(recordNum).wave")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch {
                
        }
    }

    //HELPER FUNCTIONS
    //run the timer
    @objc func runTimer() {
        counter += 0.1
        let floorCounter = Int(floor(counter))
        let minute = floorCounter / 60
        var minuteStr = "\(minute)"
        if minute < 10 {
            minuteStr = "0\(minute)"
        }
        let second = (floorCounter % 3600) % 60
        var secStr = "\(second)"
        if second < 10 {
            secStr = "0\(second)"
        }
        timerLabel.text = "\(minuteStr):\(secStr)"
    }
    
    //retrieve recording
    func getURL() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let thisDirect = path[0]
        return thisDirect
    }
    
    //Loading the recording view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImage.image = UIImage(named: "logo")
        
        //ask for permission
        if let num: Int = UserDefaults.standard.object(forKey: "myNum") as? Int {
            recordNum = num
        }
        AVAudioSession.sharedInstance().requestRecordPermission { (permission) in
            if permission {
                print("OK")
            }
        }
        
        print("RecordingViewController loaded its view")
    }

}


//extentions for rounding the recording button's corners
@IBDesignable extension UIButton {
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
