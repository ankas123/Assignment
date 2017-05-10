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
    private var mic: AKMicrophone!
    private var tracker: AKFrequencyTracker!
    private var silence: AKBooster!
    fileprivate let audioQueue: DispatchQueue = DispatchQueue(label: "Sound", attributes: [])
    fileprivate let playQueue: DispatchQueue = DispatchQueue(label: "play", qos : .utility, attributes: .concurrent)

    fileprivate let audioSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

    
    private var audioPlayer : AVAudioPlayer!
    private var session : AVAudioSession!
    private var audioRecorder : AVAudioRecorder!
    private var NsPath: URL!
    
    private let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    private let recordName = "text.m4a"


    private var frequencies  = [Float]()
    var bitArray = [Int]()
    
    
    
    private let kFrameCapacity = AVAudioFrameCount(256)
    
    
    open class func shared() -> SoundInterpreter {
        return soundInterpreter
    }
    
    struct bitPacket {
        var bit : Int = 0
        var duration : Float = 0.0
    }
    
    var packet = bitPacket()

    

    
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
  }
    

    

    
    func readFromFile(){
        audioRecorder.stop()
        
        
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)
        
        var audioBuffers: [AVAudioPCMBuffer] = [AVAudioPCMBuffer]()
        
        var file : AVAudioFile = AVAudioFile()
        
        
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
        
        var bits =  [bitPacket]()
            //audio Buffer has the samples
       
            
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
        
            
    
        
        for i in bits{
            print("\(i.bit) \(i.duration) " )
        }
        
        //print(bit)
        decode(bit: bits)


    }
    
    
    func fftForBuffer(buffer : AVAudioPCMBuffer, duration : Float) -> Int{
        let fft = TempiFFT(withSize: 256, sampleRate: 44100)
        
        let floatArray = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count:Int(buffer.frameLength)))

        
        
        fft.windowType = TempiFFTWindowType.hanning
            
            //print(buffer.floatChannelData)
            fft.fftForward(floatArray)
            
            var mag = Float(0)
        
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

      
        
        
        
        return -1
        
    }
    
    func decode(bit :  [bitPacket] ) {
        var bits = [UInt8]()
        if bit.count > 1{
        let times = bit[1].duration
        
        for i in 1...bit.count-1 {
            
            var count = Int(bit[i].duration / times)
            
            if (bit[i].duration.truncatingRemainder(dividingBy: times)) > (times * 0.5){
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
        let conv = Conversion()
        conv.toChar(recieve: bits)
        }
    }
    
    
}
