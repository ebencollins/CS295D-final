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
    var audioURL:URL!
    
    // run when a view is loaded for the first time
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("RecordingViewController loaded")
        // TODO this whole thing should be done on a thread with a processing dialog
        do {
            let file = try AVAudioFile(forReading: audioURL)
            let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32,
                                       sampleRate: file.fileFormat.sampleRate,
                                       channels: file.fileFormat.channelCount,
                                       interleaved: file.fileFormat.isInterleaved)
            
            let buf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(file.length))
            try file.read(into: buf!)
            
            let size = Int(buf!.frameLength)
            let samples = Array(UnsafeBufferPointer(start: buf?.floatChannelData![0], count:size))
            let data = EssentiaWrapper().extract(samples);
            
            var mb96 = data?.mb96 as! [[Float]]
            mb96 = mb96.map({ $0.map{ log10($0) } }).transposed()
            
            let renderer = AGGRenderer()
            var hm = Heatmap<[[Float]]>(mb96);
            hm.colorMap = ColorMap.viridis
            hm.showGrid = false
            hm.plotTitle = PlotTitle("Title")
            
            hm.markerTextSize = 0
            hm.markerThickness = 0
            hm.drawGraph(size: Size(width: Float(CGFloat(1200)), height: Float(768)), renderer: renderer)
            
            let image = UIImage(data: NSData(base64Encoded: renderer.base64Png())! as Data)
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
        }
        catch {
            print("Error procesing")
            // TODO: dialog
        }
        
    }
    
}
