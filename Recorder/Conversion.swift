//
//  Conversion.swift
//  Recorder
//
//  Created by Anant on 06/05/17.
//  Copyright © 2017 Anant. All rights reserved.
//

import Foundation

class Conversion{
    
    
    func toBinary(value : String) -> [UInt8]{
        var buffer = [UInt8]()
        var bits = [UInt8]()
        for char in value.utf8{
            buffer += [char]
        }
        print(buffer)
        bits = self.binarySegregation(Buffer: buffer)
        return bits
    }
    
    
    func binarySegregation(Buffer: [UInt8]) -> [UInt8]{
        var bits = [UInt8]()
        for var i in Buffer{
            //print(i)
            for _ in 1...8{
                bits += [i & 0b0000_0001]
                // print(i & 0b0000_0001)
                i = i>>1
            }
            
        }
        
        //self.toChar()
        return bits     //MSB First
        
    }
    
    func toChar(recieve : [UInt8]){
        var count = 0
        var str = [UInt8]()
        var temp: UInt8 = 0b0000_0000
        for i in recieve.reversed(){
            //print("count + " + String(count))
            
            if count == 7 {
                //print(i)
                temp = temp | i
                //print(temp)
                str.append(temp)
                //print(str)
                count = 0
                temp = 0b0000_0000
                continue
            }else
            { //print(i)
                temp = temp | i
                temp = temp << 1
            }
            count += 1
        }
        
        print(String(bytes: str.reversed(), encoding: String.Encoding.ascii)!)
    }
    
}
