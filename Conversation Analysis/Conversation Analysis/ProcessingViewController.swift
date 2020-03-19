//
//  ProcessingViewController.swift
//  Conversation Analysis
//
//  Created by devon on 2/21/20.
//  Copyright © 2020 conversation-analysis. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftPlot
import AGGRenderer

class ProcessingViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var recordingVC:RecordingViewController!
    
    // run when a view is loaded for the first time
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        // show alert
        self.showProcessingAlert()
        // run in background
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // open audio file that was passed
                let file = try AVAudioFile(forReading: self.recordingVC.getAudioFileURL())
                let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32,
                                           sampleRate: file.fileFormat.sampleRate,
                                           channels: file.fileFormat.channelCount,
                                           interleaved: file.fileFormat.isInterleaved)
                // read to buffer
                let buf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(file.length))
                try file.read(into: buf!)
                
                // load buffer to array and process via objectivec++ essentia wrapper
                let samples = Array(UnsafeBufferPointer(start: buf?.floatChannelData![0], count:Int(buf!.frameLength)))
                let data = EssentiaWrapper().extract(samples);
                
                // cast to 2d float array, log normalize, and transpose
                var mb96 = data?.mb96 as! [[Float]]
                mb96 = mb96.map({ $0.map{ log10($0) } }).transposed()
                
                // create heatmap
                let renderer = AGGRenderer()
                var hm = Heatmap<[[Float]]>(mb96);
                hm.colorMap = ColorMap.viridis
                hm.showGrid = false
                hm.plotTitle = PlotTitle("Title")
                
                hm.markerTextSize = 0
                hm.markerThickness = 0
                hm.drawGraph(size: Size(width: Float(CGFloat(1200)), height: Float(768)), renderer: renderer)
                
                DispatchQueue.main.async {
                    // dismiss loading view
                    self.dismiss(animated: true, completion: nil)
                    // show plot
                    let image = UIImage(data: NSData(base64Encoded: renderer.base64Png())! as Data)
                    self.imageView.image = image
                    self.imageView.contentMode = .scaleAspectFit
                }
                
            }
            catch {
                // return to recording view with result error
                DispatchQueue.main.async {
                    self.recordingVC.processingViewResult = .ERROR
                    self.dismiss(animated: false, completion: { // dismiss loading
                        self.dismiss(animated: true, completion: nil) // dismiss view
                    })
                }
            }
        }
        
    }
    
    // displays popup please wait loading indicator
    func showProcessingAlert(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func onSave(_ sender: Any) {
        // TODO: save, etc
        self.recordingVC.processingViewResult = .OK_SAVED
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.recordingVC.processingViewResult = .OK_DELETED
        self.dismiss(animated: true, completion: nil)
    }
}

enum ProcessingViewResult {
    case OK_SAVED
    case OK_DELETED
    case ERROR
}
