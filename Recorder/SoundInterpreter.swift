//
//  SoundInterpreter.swift
//  Recorder
//
//  Created by Anant on 07/05/17.
//  Copyright © 2017 Anant. All rights reserved.
//

import Foundation
import AudioKit
import AVFoundation


fileprivate let soundInterpreter: SoundInterpreter = SoundInterpreter()

class SoundInterpreter: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate  {
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    fileprivate let audioQueue: DispatchQueue = DispatchQueue(label: "Sound", attributes: [])
    fileprivate let playQueue: DispatchQueue = DispatchQueue(label: "play", qos : .utility, attributes: .concurrent)

    fileprivate let audioSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

    
    var audioPlayer : AVAudioPlayer!
    var session : AVAudioSession!
    var audioRecorder : AVAudioRecorder!
    var NsPath: URL!
    
    let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let recordName = "text.m4a"

    var operationQueue = OperationQueue()

    private var frequencies  = [Float]()
    var bitArray = [Int]()
    
    
    open class func shared() -> SoundInterpreter {
        return soundInterpreter
    }
    
    
    fileprivate override init(){
        
        
        }
    
    
    
    func record(){
        //Path Deffining
        let pathArray = [dirPath, recordName]
        NsPath = NSURL.fileURL(withPathComponents: pathArray)
        
        
        
        
        //New session
        session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
        }catch let error{
            print(error)
        }
        
        //Audio Recorder implementation
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: 0,
            AVLinearPCMIsFloatKey: 0,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey:1
        ]
        
        do {
            try audioRecorder = AVAudioRecorder(url: NsPath!, settings: settings)
            print(NsPath)
        } catch let error{
            print(error)
        }
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.delegate = self
        print("recording")
        audioRecorder.record()
        
        
        
    }
    
     func recorderStop() {
        
        //Stopping the audio recorder
        audioRecorder.stop()
//        print("stopping")
//        
//        //Deactivating the session
//        let audioSession = AVAudioSession.sharedInstance();
//        do{
//            try audioSession.setActive(false);
//        } catch let error{
//            print(error)
//        }
//        do {
//            
//            audioPlayer = try AVAudioPlayer(contentsOf: NsPath)
//        } catch let error {
//            print(error);
//        }
//        
//        session = AVAudioSession.sharedInstance()
//        do{
//            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
//            try session.setActive(true)
//            
//        } catch let error {
//            print(error)
//        }
//        
//        //Audio Player play
//        audioPlayer.delegate = self 
//        audioPlayer.play()
//        
        let file :AVAudioFile
        let akfile : AKAudioFile
        let tracker : AKFrequencyTracker
        let audioPlayer : AKAudioPlayer
        
        do{
            file = try AVAudioFile(forReading: NsPath )
            akfile = try AKAudioFile(forReading: file.url)
            print(akfile.sampleRate)
        
            audioPlayer = try AKAudioPlayer(file: akfile, looping: false,completionHandler: stopOperation  )
            
            tracker = AKFrequencyTracker(audioPlayer, hopSize: 256)
            
           
            AudioKit.output = tracker
            AudioKit.start()
            operationSetup(player: audioPlayer, tracker: tracker)
            
            
        
        } catch let error{
            print(error)
        }
        
      
    }
    
    func operationSetup(player: AKAudioPlayer, tracker: AKFrequencyTracker){
        let operation1 : BlockOperation = BlockOperation (block: {
            self.checkFrequency(player: player, tracker: tracker)
            })
         operationQueue.addOperation(operation1)
    }
    
     @objc func checkFrequency(player: AKAudioPlayer, tracker: AKFrequencyTracker){
        player.play()
        var previous = Float()
        var bit = 0b0
        var count = 0
        while true{
                if tracker.amplitude > 0.1 {
                    
                    var frequency = Float(tracker.frequency)
                    //print(frequency)
                     if -100.0 ... 100.0 ~= (frequency - 3000.0){
                    //self.frequencies.append(frequency)
                        //print(1)
                        bit = 0b1
                        
                    }
                    if -100.0 ... 100.0 ~= (frequency - 1800.0){
                        //self.frequencies.append(frequency)
                        //print(0)
                        bit = 0b0
                        
                    }
                    
//                    if bit == previous {
//                      
//                        count += 1
//                        
//                    } else {
//                        //print(bit)
//                        bitArray.append(count)
//                        count = 0
//                        previous = bit
//                    }
//                   
                    if frequency == previous {
                        
                    } else {
                        print(frequency)
                        previous = frequency
                    }
                    
                    usleep(1)
                    
            }

        }
        
    }
    
    
    func stopOperation(){
        operationQueue.cancelAllOperations()
        print(frequencies.count)
        AudioKit.stop()
       // getCount()
        
    }
    
    func getCount(){
        
        var bitcount = 0
        print(bitArray)
        if(bitArray[3] < bitArray[1]){
            
            bitcount = bitArray[3]
            
        } else {
            
            bitcount = bitArray[1]
        }
        var repeater = 0
                var bit = [UInt8]()
            for i in 1...bitArray.count-1{
            
            print(String(i) + " " + String(bitArray[i] % bitcount) + " " + String(bitArray[i] / bitcount))
            repeater = bitArray[i] / bitcount
            print(bitcount - (bitArray[i] % bitcount))
//            if  (bitcount - (bitArray[i] % bitcount)) < (bitcount * 0.50){
//                repeater += 1
//            }
//            
//            if i % 2 == 0 {
//                for j in 0...repeater {
//                    bit.append(0b0)
//                }
//                
//            }
//            else {
//                for j in 0...repeater{
//                    bit.append(0b1)
//                }
//            }
            repeater = 0
            
        }
        
        print(bit)
        bit = []
//        var value = 0
//        var zeros = 0
//        var ones = 0
//
//        if bit.count != 0{
//            for i in 0...bit.count-2{
//                if bit[i] == bit[i+1]{
//                    value += 1
//                    
//                }
//                else {
//                    var display = String(bit[i]) + "   " + String(value)
//                    if bit[i] == .allZeros{
//                        zeros += 1
//                        
//                    }
//                    else {
//                        ones += 1
//                        
//                    }
//                    //print(display)
//                    value = 0
//                }
//                
//            }
//        }
//        print("0: " + String(zeros) + " 1: " + String(ones) )
//        zeros = 0
//        ones = 0
    }
    
    func track(){
        record()
        
        bitArray = []
        
    }

    
    @objc func check(){
        audioSemaphore.signal()
    }

    
    
    
    
    
    
    
    let kFrameCapacity = AVAudioFrameCount(256)

    
    var magi = [Float]()
    var magi2 = [Float]()

    struct bitPacket {
        var bit : Int = 0
        var duration : Float = 0.0
    }
    
    var packet = bitPacket()
    
    func readFromFile(){
        audioRecorder.stop()
        
        
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)
        
        var audioBuffers: [AVAudioPCMBuffer] = [AVAudioPCMBuffer]()
        
        var file : AVAudioFile = AVAudioFile()
        
        var bufferIndex: Int = 0
        
        for _ in 0...2{
            
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: kFrameCapacity)
            
            audioBuffers.append(buffer)
       
        }

        
        do{
            
            // File to AvAudio File
            file = try AVAudioFile(forReading: NsPath )
        
        
        } catch let error {
            
            print(error)
        }
        
        var i = 0
        var checkPacket = bitPacket()
        
        var count = 0
        var bits =  [bitPacket]()
            //audio Buffer has the samples
       // playQueue.async {
            
            while file.framePosition != file.length{
                do {
                    
                    //print(file.framePosition)
                   // print(audioBuffers[i])
                    
                    try file.read(into: audioBuffers[i] , frameCount:  kFrameCapacity)
                    
                } catch let error {
                    
                    print(error)
                    
                }
                
                //print(file.length)
                //print(file.framePosition)
                
                var value = fftForBuffer(buffer: audioBuffers[i], duration: (Float(file.framePosition) / Float(kFrameCapacity)))
                if value == -1 {
                    value = checkPacket.bit
                } else {
                    if checkPacket.bit == value{
                        
                    } else {
                        checkPacket.duration = packet.duration - checkPacket.duration - 0.005
                        bits.append(checkPacket)
                        checkPacket.bit = value
                        checkPacket.duration = packet.duration
                            
                            
                        }
                    }
                
                }
           // }
            
    
        
        for i in bits{
            print("\(i.bit) \(i.duration) " )
        }
        
        //print(bit)
        decode(bit: bits)


    }
    
    
    func fftForBuffer(buffer : AVAudioPCMBuffer, duration : Float) -> Int{
        let fft = TempiFFT(withSize: 256, sampleRate: 44100)
        
        let floatArray = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count:Int(buffer.frameLength)))

       // play.async{
        
        
        fft.windowType = TempiFFTWindowType.hanning
            
            //print(buffer.floatChannelData)
            fft.fftForward(floatArray)
            
            var mag = Float(0)
            //var magat = fft.magnitudeAtFrequency(14000)
            
            for i in 1...200{
                
                mag = fft.sumMagnitudes(lowFreq: Float(100.0 * i) , highFreq: Float(100.0 * (i + 1)), useDB: false)
                
                if (100000 > mag) && (mag > 600.0){
                    
                    //print(String(duration * 0.005) + " " + String(i) + "  " + String(mag))

                    if i == 18
                    {
                    
                        print(String(duration * 0.005) + " 0" )
                        
                        
                        packet.bit = 0
                        packet.duration = duration * 0.005
                        return 0
                    }
                    
                    if i == 30
                    {
                        print(String(duration * 0.005) + " 1")
                       
                        packet.bit = 1
                        packet.duration = duration * 0.005
                        return 1
                    }
                }
            }

      //  }
        
        //magi.append(mag)
        //magi2.append(magat)
        
        return -1
        
    }
    
    func decode(bit :  [bitPacket] ) {
        var bits = [UInt8]()
        if bit.count > 1{
        var times = bit[1].duration
        
        for i in 1...bit.count-1 {
            
            var count = Int(bit[i].duration / times)
            
            if (bit[i].duration.truncatingRemainder(dividingBy: times)) > (times * 0.4){
                count += 1
            }
            
            if count == 0 {
                count += 1
            }
           
            for _ in 0...count-1{
                if bit[i].bit == 0{
                    bits.append(0b0)
                } else {
                    bits.append(0b1)
                }
            }
            
            
        }
        bits.append(0b0)
        bits.append(0b0)
        bits.insert(0b0, at: 0)
        bits.insert(0b0, at: 0)
        print(bits)
        var conv = Conversion()
        conv.toChar(recieve: bits)
        }
    }
    
    
}
