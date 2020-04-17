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
import CoreData

class ProcessingViewController: UIViewController {
    
    var date:Date?
    var duration:Int?
    var segments:[(duration: Int, start:Int, imageData:Data)] = []
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet var dataCollectionSucessesful: UILabel!
    @IBOutlet var audioRecordingDeleted: UILabel!
    @IBOutlet var timeInterval: UILabel!
    @IBOutlet var sendDataForResearch: UILabel!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
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
                
                try self.deleteAudioFile()
                
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
                
                let imageData = Data(base64Encoded: renderer.base64Png())
                
                self.date = Date()
                self.duration = samples.count / file.fileFormat.sampleRate.toInt()
                self.segments.append((duration: 0, start: 0, imageData: imageData!))
                
                // TESTING
                // cast to 2d float array, log normalize, and transpose
                let dropAmount = ((data?.mb96.count)!)/2
                var mb962 = data?.mb96.dropLast(dropAmount) as! [[Float]]
                mb962 = mb962.map({ $0.map{ log10($0) } }).transposed()
                
                // create heatmap
                var hm2 = Heatmap<[[Float]]>(mb962);
                hm2.colorMap = ColorMap.viridis
                hm2.showGrid = false
                hm2.plotTitle = PlotTitle("Title")
                hm2.markerTextSize = 0
                hm2.markerThickness = 0
                hm2.drawGraph(size: Size(width: Float(CGFloat(1200)), height: Float(768)), renderer: renderer)
                
                let imageData2 = Data(base64Encoded: renderer.base64Png())
                self.segments.append((duration: 0, start: 0, imageData: imageData2!))
                
                DispatchQueue.main.async {
                    // dismiss loading view
                    self.dismiss(animated: true, completion: nil)
                    // show plot
                    let image = UIImage(data: imageData!)
                    self.imageView.image = image
                    self.imageView.contentMode = .scaleAspectFit
                    
                    // let image2 = UIImage(data: imageData!.prefix(through: imageData!.count/2))
                    let image2 = UIImage(data: imageData2!)
                    self.imageView2.image = image2
                    self.imageView2.contentMode = .scaleAspectFit

                    // unhide everything
                    self.setHidden(false)
                }
                
            }
            catch {
                try? self.deleteAudioFile()
                
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
    
    func deleteAudioFile() throws {
        try FileManager.default.removeItem(at: self.recordingVC.getAudioFileURL())
    }
    
    @discardableResult func saveImage(uuid: UUID, data: Data) throws -> URL {
        let imagesDir = self.recordingVC.getURL().appendingPathComponent("images")
        // try? because dir may already exist
        try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: false, attributes: nil)
        // raise if there's an error creating the file though
        let imagePath = imagesDir.appendingPathComponent("\(uuid).png")
        try data.write(to: imagePath)

        return imagePath.absoluteURL
    }
    
    func setHidden(_ hidden:Bool) {
        if(hidden) {
            // hides objects
            dataCollectionSucessesful.isHidden = true
            audioRecordingDeleted.isHidden = true
            imageView.isHidden = true
            timeInterval.isHidden = true
            sendDataForResearch.isHidden = true
            sendButton.isHidden = true
            cancelButton.isHidden = true
        } else {
            // unhides objects
            dataCollectionSucessesful.isHidden = false
            audioRecordingDeleted.isHidden = false
            imageView.isHidden = false
            timeInterval.isHidden = false
            sendDataForResearch.isHidden = false
            sendButton.isHidden = false
            cancelButton.isHidden = false
        }
    }
    
    @IBAction func onSave(_ sender: Any) {
        // save extracted data to database and images to file
        do {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate!.persistentContainer.viewContext
            // create conversation and segments based on data form processing
            let conversation = Conversation(context: managedContext)
            conversation.date = self.date
            conversation.uuid = UUID()
            
            for (duration, segmentStart, imageData) in self.segments {
                let segment = ConversationSegment(context: managedContext)
                segment.uuid = UUID()
                try saveImage(uuid: segment.uuid, data: imageData)
                segment.duration = Int32(duration)
                segment.start_time = Int32(segmentStart)
                segment.conversation = conversation
            }
            try managedContext.save()
            self.recordingVC.lastConversation = conversation
            self.recordingVC.processingViewResult = .OK_SAVED
        }
        catch {
            self.recordingVC.lastConversation = nil
            self.recordingVC.processingViewResult = .ERROR
        }
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
