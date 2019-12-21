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
    var datedayuse = "nil"
    var datetimeuse = "nil"
    
    
    struct teacherjsonstruct:Decodable{
        let aka:String
        let name:String
    
    }
    var arrdatateacher=[teacherjsonstruct]()
    
    struct roomjsonstruct:Decodable{
        let room:String
          
    }
    var arrdataroom=[roomjsonstruct]()
    
    struct responjsonstruct:Decodable{
           let room:String
             
       }
    var arrdatarespon=[responjsonstruct]()
    var find:String = "non"
    var type:String = "0"
    
    let t_CHR = ["เจี๊ยบวุต", "เฉียบวุต", "เชียบวุต","เชื่อวุต"]
    let t_ENS = ["เอิน", "เอิร์น"]
    let t_GDP = ["กฤษฎาพัฒน์", "เกดนภัส"]
    let t_KAB = ["คันธารัตย์"]
    let t_KSB = ["กอบเกียรติ์"]
    let t_PRV = ["ปรวัติ"]
    let t_SSP = ["สถิต"]
    let t_SWK = ["สุวัฒชัย"]
    let t_PLS = ["ปัดชญาภรณ์","ปัดเชียร์พร","ปัดเชียร์ยาก่อน","พัทยาพร","ปรัชยาพร","ปัดเชียร์ยาภรณ์","รัชญาพร"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        readDataTeacher()
        readDataRoom()
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
        if (checkstate == 1) {
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
                
                self.postData(textinput: textinputtemp!)

                
              
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
    
    func readDataTeacher()  {
              print("Starting GET Data Teacher")
              let url = URL(string:"http://172.25.176.251:8084/WebApplication/jsondata.json")
              URLSession.shared.dataTask(with: url!) {
                  (data, response, error) in
                  do{if error == nil{
                      self.arrdatateacher = try JSONDecoder().decode([teacherjsonstruct].self, from: data!)
                      for mainarr in self.arrdatateacher{
                        print(mainarr.aka,":",mainarr.name)
                          
                      }
                      print("number of list",self.arrdatateacher.count)
                      }
                  }catch{
                      print("Error in get json data teacher")
                  }
              }.resume()
    }
    func readDataRoom()  {
        print("Starting GET Data Room")
        let url = URL(string:"http://172.25.176.251:8084/WebApplication/roomjsondata.json")
//        let url = URL(string:"http://172.25.176.251:8084/WebApplication/output.json")
//        let url = URL(string:"http://172.25.176.251:8084/WebApplication/get.jsp")
        
        URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            do{if error == nil{
               
                self.arrdataroom = try JSONDecoder().decode([roomjsonstruct].self, from: data!)
                for mainarr in self.arrdataroom{
                    print(mainarr.room)
                }
                print("number of list",self.arrdataroom.count)
                }
            }catch{
                print("Error in get json data room")
            }
        }.resume()
    }
    
    func postData(textinput:String) {
        type = "0"
        let formatter1 = DateFormatter()
               let formatter2 = DateFormatter()
                      //2016-12-08 03:37:22 +0000
               formatter1.dateFormat = "EEEE"
               formatter2.dateFormat = "HH:mm"
               let now = Date()
               let dateString = formatter1.string(from:now)
               datedayuse = dateString
               let dateString2 = formatter2.string(from: now)
               datetimeuse = dateString2
               print("Time Now : ",datedayuse,datetimeuse)
        
        for mainarr in self.arrdataroom{
                         print("Searching....room",mainarr)
                         if textinput.contains(mainarr.room) {
                            find = mainarr.room
                            type = "1"
                            print("Find = "+find)
                            break
                }
        }
    
               
               for mainarr in self.arrdatateacher{
                                 print("Searching....Teacher",mainarr)
                                 if textinput.contains(mainarr.name) {
                                      find = mainarr.aka
                                      type = "2"
                                    print("Find = "+find)
                                    break
                           }
               }
               for mainarr in self.t_CHR{
                   print("Searching....CHR",mainarr)
                       if textinput.contains(mainarr) {
                           find = "CHR"
                           type = "2"
                        print("Find = "+find)
                          }
               }
               for mainarr in self.t_ENS{
                          print("Searching....ENS",mainarr)
                              if textinput.contains(mainarr) {
                               find = "ENS"
                                  type = "2"
                                print("Find = "+find)
                   }
               }
               for mainarr in self.t_GDP{
                   print("Searching....GDP",mainarr)
                       if textinput.contains(mainarr) {
                           find = "GDP"
                           type = "2"
                        print("Find = "+find)
                          }
               }
               for mainarr in self.t_KAB{
                   print("Searching....KAB",mainarr)
                       if textinput.contains(mainarr) {
                           find = "KAB"
                           type = "2"
                        print("Find = "+find)
                          }
               }
               for mainarr in self.t_KSB{
                   print("Searching....KSB",mainarr)
                       if textinput.contains(mainarr) {
                           find = "KSB"
                           type = "2"
                          }
               }
               for mainarr in self.t_PRV{
                   print("Searching....PRV",mainarr)
                       if textinput.contains(mainarr) {
                           find = "PRV"
                           type = "2"
                          }
               }
               for mainarr in self.t_SSP{
                   print("Searching....SSP",mainarr)
                       if textinput.contains(mainarr) {
                           find = "SSP"
                           type = "2";
                          }
               }
               for mainarr in self.t_SWK{
                   print("Searching....SWK",mainarr)
                       if textinput.contains(mainarr) {
                           find = "SWK"
                           type="2";
                          }
               }
               for mainarr in self.t_PLS{
                          print("Searching....PLS",mainarr)
                              if textinput.contains(mainarr) {
                                  find = "PLS"
                                  type="2";
                                 }
                      }
        
        if (type == "1" || type == "2"){
            let alert = UIAlertController(title: "คุณต้องการที่จะค้นหา", message: find, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                print("Push : Yes")
                let url = URL(string:"http://172.25.176.251:8084/WebApplication/get.jsp?text="+self.find+"&day="+self.datedayuse+"&timestart="+self.datetimeuse+"&type="+self.type)
                print(url as Any)
                URLSession.shared.dataTask(with: url!) {
                    (data, response, error) in
                    do{if error == nil{
                       DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                           print("Done")
                       })
                        self.arrdatarespon = try JSONDecoder().decode([responjsonstruct].self, from: data!)
                        for mainarr in self.arrdatarespon{
                            print(mainarr.room)
                        }
                        print("number of list",self.arrdatarespon.count)
                        }
                    }catch{
                        print("Error in get json data room")
                    }
                }.resume()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                print("Push : No")
            }))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "ไม่พบข้อความที่คุณค้นหา กรุณาลองใหม่อีกครั้ง", message: textinput, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "try agian", style: .default, handler: { action in
                print("try agian")
             }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
