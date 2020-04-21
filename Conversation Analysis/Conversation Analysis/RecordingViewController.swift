//
//  RecordingViewController.swift
//  Conversation Analysiseb
//
//  Created by devon on 2/18/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import NotificationBannerSwift

class RecordingViewController: UIViewController, AVAudioRecorderDelegate {
    let AUDIO_FILENAME = "recording.wav"
    let MIN_RECORDING_LENGTH = 20.0
    
    var recorder : AVAudioRecorder!
    var playSound : AVAudioPlayer!
    var audioPlayer : AVAudioPlayer!
    
    var recordNum = 0
    var timer = Timer()
    var isRecording = false
    var counter = 0.0
    
    
    var processingViewResult:ProcessingViewResult?
    var lastConversation:Conversation?
    
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBAction func record(_ sender: Any) {
        // check that we are not already recording
        if recorder == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
            
            let settings = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 32,
                AVLinearPCMIsFloatKey: true,
                AVLinearPCMIsBigEndianKey: false,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ] as [String : Any]
            
            do {
                recorder = try AVAudioRecorder(url: getAudioFileURL(), settings: settings)
                recorder.delegate = self
                recorder.record()
                button.setBackgroundImage(UIImage(systemName: "stop.circle"), for: .normal)
                
            } catch {
                showErrorAlert()
            }
            
        } else {
            //stop recording
            recorder.stop()
            button.setBackgroundImage(UIImage(systemName: "mic.fill"), for: .normal)
            recorder = nil
            
            timer.invalidate()
            
            //process
            if counter >= MIN_RECORDING_LENGTH {
                self.performSegue(withIdentifier: "DataProcessingSegue", sender: nil)
            } else{
                try? FileManager.default.removeItem(at: getAudioFileURL());
                let banner = NotificationBanner(title: "Discarded", subtitle: "Recording has been discarded successfully.", style: .success)
                banner.show()
            }
            
            // reset timer back to 00:00
            counter = 0.0
            timerLabel.text = "00:00"
            
        }
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getAudioFileURL())
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
    
    func getAudioFileURL() -> URL {
        return getURL().appendingPathComponent("\(recordNum).wave")
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
                print("Permision Granted")
            }
        }
        
        // register device with API of not already registered
        ConversationsAPIClient.registerDevice(completion: {result in
              let banner = NotificationBanner(title: "Device registered", subtitle: "This device has been successfully registered with the remote server", style: .success)
              banner.show()
          })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let result = self.processingViewResult {
            switch result {
            case .OK_SAVED:
                self.performSegue(withIdentifier: "RecordingProcessedDetailViewSegue", sender: nil)
            case .OK_DELETED:
                // display toast
                showToast(message: "Deleted")
                let banner = NotificationBanner(title: "Discarded", subtitle: "Recording has been discarded successfully.", style: .success)
                banner.show()
            case .ERROR:
                showErrorAlert()
            }
            self.processingViewResult = nil;
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DataProcessingSegue") {
            let vc = segue.destination as! ProcessingViewController
            vc.recordingVC = self
        } else if (segue.identifier == "RecordingProcessedDetailViewSegue") {
            let vc = segue.destination as! DetailGraphView
            if let conversation = self.lastConversation {
                vc.conversation = conversation
            } else {
                showErrorAlert()
            }
        }
    }
    
    func showErrorAlert(){
        let alert = UIAlertController(title: "Oops!", message: "Something went wrong!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showToast(message: String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
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
