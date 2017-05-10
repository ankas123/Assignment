//
//  TextOnAirController.swift
//  Recorder
//
//  Created by Anant on 07/05/17.
//  Copyright © 2017 Anant. All rights reserved.
//

import UIKit

class TextOnAirController: UIViewController {

    @IBOutlet weak var stop: UIButton!
    @IBOutlet weak var recieve: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func recieve(_ sender: UIButton) {
        recieve.isEnabled = false
        stop.isEnabled = true
        
        
        SoundInterpreter.shared().record()
    }
    
    @IBAction func play(_ sender: UIButton) {
        FMSynthesizer.sharedSynth().play(toSend: "$ab$")
    }
    @IBAction func Stop(_ sender: UIButton) {
        
        recieve.isEnabled = true
        stop.isEnabled = false
        
        SoundInterpreter.shared().recorderStop()

        SoundInterpreter.shared().readFromFile()
    }
    

}
