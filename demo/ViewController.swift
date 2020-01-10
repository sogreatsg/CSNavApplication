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
  
   
    var lm = CLLocationManager()
    @IBOutlet weak var recordButton: UIButton!
    var ipserver = "172.20.10.3"
    
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
    var rssi = 0
    var datedayuse = "nil"
    var datetimeuse = "nil"
//    var scene = SCNScene(named: "art.scnassets/26198.scn")
    var scene = SCNScene()
    
    var dir = "null"
    
    
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
        let x:Double
        let y:Double
        let z:Double
             
       }
    var arrdatarespon=[responjsonstruct]()
    var find:String = "non"
    var type:String = "0"
    var respondx = "nil"
    var respondy = "nil"
    var respondz = "nil"
    
    let t_AWS = [""]
    let t_LPP = ["หรือพล","ลืพล","ลืมพล","ลืมล","ลืมโอน"]
    let t_ENS = ["เอิน", "เอิร์น"]
    let t_ADP = [""]
    let t_CHR = ["เจี๊ยบวุต", "เฉียบวุต", "เชียบวุต","เชื่อวุต","เชียร์คุณ","เฉียบพูด"]
    let t_BLT = [""]
    let t_GDP = ["กฤษฎาพัฒน์", "เกดนภัส","กิ๊บดำผัด","กฤษดาผัก","ปริศฎาพัด"]
    let t_KAB = ["คันธารัตย์"]
    let t_KSB = ["กอบเกียรติ์"]
    let t_NKS = ["ได้ก่อน","นึกก่อน","นิก่อน"]
    let t_NSN = [""]
    let t_PLS = ["ปัดชญาภรณ์","ปัดเชียร์พร","ปัดเชียร์ยาก่อน","พัทยาพร","ปรัชยาพร","ปัดเชียร์ยาภรณ์","รัชญาพร"]
    let t_PRV = ["ปรวัติ","ประวัติ","ปาราวัด"]
    let t_SSP = ["สถิต"]
    let t_SWK = ["สุวัฒชัย","สุวรรณชัย","ถ้วย","ช่วย"]
    let t_TNA = ["ธนภัทร","ธนพัฒน์"]
    let t_NSD = ["นัดทะวุด","นัดทวุฒิ"]
    
    
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
//
//        var position = SCNVector3(0, -0.5, -1)
//
//                   // 2
//        var mars = createArrow(at: position)
//        scene.rootNode.addChildNode(mars)
//
//                position = SCNVector3(0, -0.5, -2)
//
//                          // 2
//                mars = createArrow(at: position)
//               scene.rootNode.addChildNode(mars)
//
//                position = SCNVector3(0, -0.5, -3)
//
//                          // 2
//                mars = createArrow(at: position)
//               scene.rootNode.addChildNode(mars)
//
//                position = SCNVector3(0, -0.5, -4)
//
//                          // 2
//                mars = createArrow(at: position)
//               scene.rootNode.addChildNode(mars)
//
//                position = SCNVector3(0, -0.5, -5)
//
//                          // 2
//                mars = createArrow(at: position)
//               scene.rootNode.addChildNode(mars)
//
//
      
        sceneView.scene = scene
        lm = CLLocationManager()
        lm.delegate = self
        lm.distanceFilter = 1000
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        if CLLocationManager.headingAvailable() {
            lm.headingFilter = 5
            lm.startUpdatingHeading()
        }
       

              // Start location services to get the true heading.
       
        locationManager.startUpdatingLocation()
       
        

        let text = "สวัสดีค่ะ กดปุ่มไมโครโฟนและพูดเพื่อค้นหาได้เลย"
        
        speech(text)


        
        print("viewDidLoad")
        
       

        
        let uuid = UUID(uuidString: "B5B182C7-EAB1-4988-AA99-B5C1517008D9")
//        let uuid = UUID(uuidString: "10F86430-1346-11E4-9191-0800200C9A66")
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
    func createArrow(at position: SCNVector3) -> SCNNode {
        let sphere = SCNSphere(radius: 0.2)
         
        // 2
        let node = SCNNode(geometry: sphere)
         
        // 3
        node.position = position
         
        // 4
        return node
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
                self.recordButton.isEnabled = true
            }
            
            
            
            if error != nil || isFinal {
                let textinputtemp:String?
            
                textinputtemp = result?.bestTranscription.formattedString
                print(textinputtemp as Any)
                
                self.postData(textinput: textinputtemp ?? "nil")
           
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
            rssi = zone
        }

           
        }
    
    func readDataTeacher()  {
              print("Starting GET Data Teacher")
              let url = URL(string:"http://"+ipserver+":8084/WebApplication/jsondata.json")
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
        let url = URL(string:"http://"+ipserver+":8084/WebApplication/roomjsondata.json")
        
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
        
        let rssiuse = String(rssi)
       
       
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
        if type != "2"{
            for mainarr in self.t_AWS{
               
                    if textinput.contains(mainarr) {
                        find = "AWS"
                        type = "2"
                        print("Find = "+find)
                        break
                       }
            }
        }
        if type != "2"{
        for mainarr in self.t_LPP{
//            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "LPP"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_ENS{
//            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "ENS"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_ADP{
//            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "ADP"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_CHR{
//            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "CHR"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_BLT{
//            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "BLT"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_GDP{
//            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "GDP"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_KAB{
//            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "KAB"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_KSB{
//            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "KSB"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_NKS{
//            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "NKS"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_NSN{
//            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "NSN"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_PLS{
            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "PLS"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_PRV{
            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "PRV"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_SSP{
            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "SSP"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_SWK{
            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "SWK"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_TNA{
            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "TNA"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
        }
        }
        if type != "2"{
        for mainarr in self.t_NSD{
            print("Searching....AWS",mainarr)
                if textinput.contains(mainarr) {
                    find = "NSD"
                    type = "2"
                    print("Find = "+find)
                    break
                   }
            }
            
        }
       
        if (type == "1" || type == "2"){
            let alert = UIAlertController(title: "คุณต้องการที่จะค้นหา", message: find, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                print("Push : Yes")
                let url = URL(string:"http://"+self.ipserver+":8084/WebApplication/get.jsp?text="+self.find+"&day="+self.datedayuse+"&timestart="+self.datetimeuse+"&type="+self.type+"&rssi="+rssiuse+"&dir="+self.dir)
                print(url as Any)
                URLSession.shared.dataTask(with: url!) {
                    (data, response, error) in
                    do{if error == nil{
                      
                        self.arrdatarespon = try JSONDecoder().decode([responjsonstruct].self, from: data!)
                        for mainarr in self.arrdatarespon{
                            print(mainarr.x,":",mainarr.y,":",mainarr.z)
                        }
                        print("number of list",self.arrdatarespon.count)
                        }
                     
                        self.direction()
                       
                    }catch{
                        print("Error in get json data respon")
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
    
    func direction()  {
       
        for mainarr in self.arrdatarespon{
            let position = SCNVector3(mainarr.x, mainarr.y , mainarr.z)
            let mars = createArrow(at: position)
            scene.rootNode.addChildNode(mars)
            sceneView.scene = scene

        }
//        scene = SCNScene(named: "art.scnassets/model.scn")!
     
//        let text = "เดินตามลูกศรเพื่อไปยังจุดหมายได้เลย"
//               speech(text)
//
    }
     func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            print("startdir")
           if newHeading.headingAccuracy < 0 {
               return
           }
        if (dir != "null") {
                 lm.stopUpdatingHeading()
        }

           // Get the heading(direction)
           let heading: CLLocationDirection = ((newHeading.trueHeading > 0) ?
               newHeading.trueHeading : newHeading.magneticHeading);
           UIView.animate(withDuration: 0.5) {
              
           }
          
          
            
          var strDirection = String()
           if(heading > 23 && heading <= 67){
               strDirection = "2";
           
           } else if(heading > 68 && heading <= 112){
               strDirection = "3";
           
           } else if(heading > 113 && heading <= 167){
               strDirection = "4";
       
           } else if(heading > 168 && heading <= 202){
               strDirection = "5";
       
           } else if(heading > 203 && heading <= 247){
               strDirection = "6";

           } else if(heading > 248 && heading <= 293){
               strDirection = "7";
       
           } else if(heading > 294 && heading <= 337){
               strDirection = "8";
      
           } else if(heading >= 338 || heading <= 22){
               strDirection = "1"
               
           }
        
        if (dir != strDirection){
            dir = strDirection
            print(dir)
        }
           
           
       }


   
}

