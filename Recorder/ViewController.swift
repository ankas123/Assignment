//
//  ViewController.swift
//  Recorder
//
//  Created by Anant on 27/04/17.
//  Copyright © 2017 Anant. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @IBOutlet weak var playButton: UIButton!
   
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    var beep : AVAudioPlayer!

    
    var session : AVAudioSession!
    var audioRecorder : AVAudioRecorder!
    var NsPath: URL!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view, typically from a nib.
        
        
            
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    @IBAction func Stop(_ sender: UIButton) {
        audioRecorder.stop()
       
        print("stopping")
        let audioSession = AVAudioSession.sharedInstance();
        do{
        try audioSession.setActive(false);
        } catch let error{
            print(error)
        }
        
        recordButton.isEnabled = true
        playButton.isEnabled = true
        stopButton.isEnabled = false
    }

    @IBAction func Record(_ sender: UIButton) {
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordName = "recording.m4a"
        let pathArray = [dirPath, recordName]
        NsPath = NSURL.fileURL(withPathComponents: pathArray )
        //print(NsPath as)
        session = AVAudioSession.sharedInstance()
        
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
        }catch let error{
            print(error)
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: 0,
            AVLinearPCMIsFloatKey: 0,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey:1
        ]
        
        do {
            try
        audioRecorder = AVAudioRecorder(url: NsPath!, settings: settings)
            print(NsPath)} catch let error{
            print(error)
    }
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.delegate = self
        
        print("recording")
        audioRecorder.record()
        
        recordButton.isEnabled = false
        stopButton.isEnabled = true
        playButton.isEnabled = false
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
    
    @IBAction func Play(_ sender: UIButton) {
        
        do {
            
            beep = try AVAudioPlayer(contentsOf: NsPath)
        } catch let error {
            print(error);
        }
        
        recordButton.isEnabled = false
        stopButton.isEnabled = false
        
        beep.delegate = self
        beep.play()

           }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        stopButton.isEnabled = false
    }
}

