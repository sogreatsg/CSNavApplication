//
//  ViewController.swift
//  demo
//
//  Created by KITTISAK SRIDET on 28/11/2562 BE.
//  Copyright © 2562 KITTISAK SRIDET. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import RealityKit
import CoreLocation
import Speech
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate,CLLocationManagerDelegate,SFSpeechRecognizerDelegate{

    @IBOutlet var sceneView: ARSCNView!
  

    @IBOutlet weak var recordButton: UIButton!
    
    
    /// This location manager is used to demonstrate how to range beacons.
    var locationManager = CLLocationManager()
    var beaconConstraints = [CLBeaconIdentityConstraint: [CLBeacon]]()
    var beacons = [CLProximity: [CLBeacon]]()
    
    var langSpeech: String = "th-TH"
    var speechSynthesizer = AVSpeechSynthesizer()
    
    
    var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "th-TH"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    var textinput = "nil"
    var checkstate = 0
    var zone = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        recordButton.tintColor = .white
       
        locationManager.delegate = self
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/model.scn")!
        
      
      
        sceneView.scene = scene
  
        

        let text = "สวัสดีค่ะ กดปุ่มไมโครโฟนและพูดเพื่อค้นหาได้เลย"
        
        speech(text)


        
        print("viewDidLoad")
        
        
       
        let uuid = UUID(uuidString: "B5B182C7-EAB1-4988-AA99-B5C1517008D9")
        self.locationManager.requestWhenInUseAuthorization()
        
        // Create a new constraint and add it to the dictionary.
        let constraint = CLBeaconIdentityConstraint(uuid: uuid!)
        self.beaconConstraints[constraint] = []
        
        /*
        By monitoring for the beacon before ranging, the app is more
        energy efficient if the beacon is not immediately observable.
        */
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid!.uuidString)
        self.locationManager.startMonitoring(for: beaconRegion)
        print("iBeacon starting")
        
       
 
    }
    
    override func viewDidAppear(_ animated: Bool) {

      speechRecognizer.delegate = self
      requestAuthorization()
      

    }
    @IBAction func micpress(_ sender: Any) {
        if (checkstate == 0) {
            let text = "ตอนนี้คุณอยู่นอกพื้นที่ให้บริการ กรุณาลองใหม่อีกครั้ง"
            speech(text)
        }else{
            
            if audioEngine.isRunning {
               
                audioEngine.stop()
                recognitionRequest?.endAudio()
                recordButton.isEnabled = false
             
                print("StopRecording")
                recordButton.tintColor = .white
                  
                  
            
                  
              } else {
              
                
                startRecording()
              
                print("Recording")
                recordButton.tintColor = .systemBlue
              }
        }
        
          
    }
    
    
    
    
    func requestAuthorization(){
      SFSpeechRecognizer.requestAuthorization { authStatus in
          
          OperationQueue.main.addOperation {
              switch authStatus {
              case .authorized:
                  self.recordButton.isEnabled = true
                  
              case .denied:
                  self.recordButton.isEnabled = false
                  self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                  
              case .restricted:
                  self.recordButton.isEnabled = false
                  self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                  
              case .notDetermined:
                  self.recordButton.isEnabled = false
                  self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
              default :
                print("no")
            }
          }
      }
    }
    
    func startRecording()  {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false

            if result != nil {

                self.textinput = (result?.bestTranscription.formattedString)!
                isFinal = (result?.isFinal)!
//                print(self.textinput," + ",isFinal)
                self.recordButton.isEnabled = true
            }
            
            
            
            if error != nil || isFinal {
                let textinputtemp:String?
                textinputtemp = result?.bestTranscription.formattedString
                print(textinputtemp as Any)
                
                let alert = UIAlertController(title: "Zone = "+String(self.zone)+" คุณพูดว่า", message: textinputtemp, preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "ใช่", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "ไม่ใช่", style: .cancel, handler: nil))

                self.present(alert, animated: true)
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.recordButton.isEnabled = true
               
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        
        
    }
    
    
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    func speech(_ text: String) {
        
        print("Start Speech")
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string:text)
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2
        speechUtterance.voice = AVSpeechSynthesisVoice(language: langSpeech)
        speechSynthesizer.speak(speechUtterance)
        
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        print("viewWillAppear")
        
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
              
              // Stop ranging when the view disappears.
        for constraint in beaconConstraints.keys {
            locationManager.stopRangingBeacons(satisfying: constraint)
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        let beaconRegion = region as? CLBeaconRegion
        print("check state")
        if state == .inside {
            checkstate = 1
            
            // Start ranging when inside a region.
            print("iBeacon inside")
            manager.startRangingBeacons(satisfying: beaconRegion!.beaconIdentityConstraint)
        } else {
            // Stop ranging when not inside a region.
            checkstate = 0
            
           
            print("iBeacon outside")
            manager.stopRangingBeacons(satisfying: beaconRegion!.beaconIdentityConstraint)
        }
    }
      func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        var temp = 0
            /*
             Beacons are categorized by proximity. A beacon can satisfy
             multiple constraints and can be displayed multiple times.
             */
            let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
            if (knownBeacons.count > 0) {
                let closestBeacon = knownBeacons[0] as CLBeacon
                let rs = closestBeacon.minor
                temp = Int(truncating: rs)
                
               
            }
        if (temp != zone){
            zone = temp
          
        }
//            print(knownBeacons)
           
           
        
        }
}
