//
//  SoundInterpreter.swift
//  Recorder
//
//  Created by Anant on 07/05/17.
//  Copyright © 2017 Anant. All rights reserved.
//

import Foundation
import AudioKit


fileprivate let soundInterpreter: SoundInterpreter = SoundInterpreter()

class SoundInterpreter{
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    fileprivate let audioQueue: DispatchQueue = DispatchQueue(label: "Sound", attributes: [])
    fileprivate let audioSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

    

    open class func shared() -> SoundInterpreter {
        return soundInterpreter
    }
    
    
    fileprivate init(){
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
    }
    
    func track(){
        
               var previous = Float(800.0)
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(check), userInfo: nil, repeats: true)

        audioQueue.async {
            AudioKit.output = self.silence
            AudioKit.start()

            while true{
            self.audioSemaphore.wait(timeout: DispatchTime.distantFuture)

            if self.tracker.amplitude > 0.1 {
                //print("running")
                
                let frequency = Float(self.tracker.frequency)
                
              print(frequency)
                if (-100 < (100 - frequency)) && ((100 - frequency) < 100){
                    print(0)
                }
                else if  (-100 < ( 1200 - frequency)) && ( (1200 - frequency) < 100){
                    print(1)
                }
                previous = frequency
                
                }
                
            }

        }
       

    }
    
    @objc func check(){
        audioSemaphore.signal()
    }
    
    
}
