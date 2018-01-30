//
//  ViewController.swift
//  GloryDays
//
//  Created by Aldo Aram Martinez Mireles on 1/25/18.
//  Copyright © 2018 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit

import Photos
import AVFoundation
import Speech

class ViewController: UIViewController {
    @IBOutlet var questionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueButton(_ sender: UIButton) {
        self.askForPhotosPermissions()
    }
    
    func askForPhotosPermissions(){
        PHPhotoLibrary.requestAuthorization { [unowned self] (authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized{
                    self.askForAudioPermissions()
                }else{
                    self.questionLabel.text = "No tenemos los permisos necesarios para utilizar la app. Ve a configuracion y activa los permisos necesarios"
                }
            }
        }
    }
    
    func askForAudioPermissions(){
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self] (allowed) in
            DispatchQueue.main.async {
                if allowed {
                    self.askForSpeechPermissions()
                }else{
                    self.questionLabel.text = "No tenemos los permisos necesarios para utilizar la app. Ve a configuracion y activa los permisos necesarios"
                }
            }
        }
    }
    
    func askForSpeechPermissions(){
        SFSpeechRecognizer.requestAuthorization { [unowned self] (authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.permissionsCompleted()
                }else{
                    self.questionLabel.text = "No tenemos los permisos necesarios para utilizar la app. Ve a configuracion y activa los permisos necesarios"
                }
            }
        }
    }
    
    func permissionsCompleted(){
        dismiss(animated: true)
    }

}

