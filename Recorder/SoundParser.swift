//
//  TextOnSoundViewController.swift
//  Recorder
//
//  Created by Anant on 02/05/17.
//  Copyright © 2017 Anant. All rights reserved.
//

import AVFoundation
import Foundation
import AudioKit



// The maximum number of audio buffers in flight. Setting to two allows one
// buffer to be played while the next is being written.
fileprivate let kInFlightAudioBuffers: Int = 2

// The number of audio samples per buffer. A lower value reduces latency for
// changes but requires more processing but increases the risk of being unable
// to fill the buffers in time. A setting of 1024 represents about 23ms of
// samples.
fileprivate let kSamplesPerBuffer: AVAudioFrameCount = 1024

fileprivate let kSamplesPerBit: AVAudioFrameCount = 1024

// The single FM synthesizer instance.
fileprivate let gFMSynthesizer: FMSynthesizer = FMSynthesizer()


open class FMSynthesizer {
    
    // The audio engine manages the sound system.
    fileprivate let engine: AVAudioEngine = AVAudioEngine()
    
    // The player node schedules the playback of the audio buffers.
    fileprivate let playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    
    // Use standard non-interleaved PCM audio.
    let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)
    
    // A circular queue of audio buffers.
    fileprivate var audioBuffers: [AVAudioPCMBuffer] = [AVAudioPCMBuffer]()
    
    // The index of the next buffer to fill.
    fileprivate var bufferIndex: Int = 0
    
    // The dispatch queue to render audio samples.
    fileprivate var audioQueue: DispatchQueue = DispatchQueue(label: "FMSynthesizerQueue", attributes: [])

    
    // A semaphore to gate the number of buffers processed.
    fileprivate let audioSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    var duration = 10
    
    var timer : Timer!
    
    var oscillator = AKOscillator(waveform: AKTable(.square))
    
    open class func sharedSynth() -> FMSynthesizer {
        return gFMSynthesizer
    }
    
    fileprivate init() {
        // Create a pool of audio buffers.
        for _ in 0...kInFlightAudioBuffers{
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: kSamplesPerBuffer)
            audioBuffers.append(audioBuffer)
        }
        
        // Attach and connect the player node.
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: audioFormat)
        
        
        do{
            try engine.start()
        }catch let error{
            print(error)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(FMSynthesizer.audioEngineConfigurationChange(_:)), name: NSNotification.Name.AVAudioEngineConfigurationChange, object: engine)
    }
    
    open func play(toSend :String) {
        let con = Conversion()
        var bits = [UInt8]()
        var zeros = 0
        var ones = 0
        bits = con.toBinary(value: toSend)
        //bits = [0b0, 0b1, 0b0, 0b1, 0b0, 0b1, 0b0, 0b1, 0b0, 0b1, 0b0, 0b1]
        
        audioQueue.async{
            
       for i in 0...bits.count - 1{
            if i == bits.count - 1
            {
                break
            } else {
            let bit = bits[i]

            if bit == .allZeros{
               
                self.generateSine(freq: 1800.0, duration: 0.05)
                print(0)
                zeros += 1
                
            } else if bit == 0b0000_0001{
                
                self.generateSine(freq: 3000.0, duration: 0.05)
                print(1)
                 ones += 1
            }
            self.audioSemaphore.wait(timeout: DispatchTime.distantFuture)

        }
            
            }
//
//
            
            print("0: " + String(zeros) + " 1: " + String(ones) )
        
            AudioKit.stop()
        
        }
        print("done")
        
        
    }
    
    
    
    
    func generateSine( freq : Double, duration : Double){
        
        
        if oscillator.isPlaying {
            print(freq)
            oscillator.stop()
        }
        
        oscillator.amplitude = 1
        oscillator.frequency = freq
        
       
        oscillator.start()
        
        AudioKit.output = oscillator
        AudioKit.start()
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.next) , userInfo: nil, repeats: false)
        }
        

        
        }
    
     @objc func next(){
        oscillator.stop()

        timer.invalidate()
        //print("yes")
        audioSemaphore.signal()
    }
        
    

    @objc fileprivate func audioEngineConfigurationChange(_ notification: Notification) -> Void {
        NSLog("Audio engine configuration change: \(notification)")
    }
    
    
    
   
}



