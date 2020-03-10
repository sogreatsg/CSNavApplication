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
    var ipserver = "172.20.10.2"
    
    var vSpinner : UIView?
    
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
    var zoneuse = "nil"
    var rssiuse = "nil"
    var datedayuse = "nil"
    var datetimeuse = "nil"
    var scene = SCNScene()
    var dir = "nil"
    var rssisum = 0
    var numrssi = 0
    var rssiavg = 0
    
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
        let r:String
        let x:Double
        let y:Double
        let z:Double
        
    }
    var arrdatarespon=[responjsonstruct]()
    var find:String = "non"
    var type:String = "0"
    
    
    let t_AWS = [""]
    let t_LPP = ["หรือพล","ลืพล","ลืมพล","ลืมล","ลืมโอน","หรือผล","ลือ","เหลือ"]
    let t_ENS = ["เอิน", "เอิร์น","อื่น"]
    let t_ADP = ["อักขระ"]
    let t_CHR = ["เจี๊ยบวุต", "เฉียบวุต", "เชียบวุต","เชื่อวุต","เชียร์คุณ","เฉียบพูด","เจียบวุด","เชฟวุต","เฉียบนุช","เชียร์บูธ","เชียงพุทธ","เชียร์พุทธ","เฉียบวัด","เชียงวุต","เฉียบบูธ","เฉี๊ยบพุทธ","เชื่อพูด","เชียร์กู๊ด","ชาวพุทธ","เฉียบพุทธ","เฉียบ","จัดบูธ","เชฟพุทธ","เชี่ยวกู๊ด","เชียร์บุตร","เชฟบูธ"]
    let t_BLT = ["เบญญาพร","เบนจะพร"]
    let t_GDP = ["กฤษฎาพัฒน์", "เกดนภัส","กิ๊บดำผัด","กฤษดาผัก","ปริศฎาพัด","กิจจาพัฒน์","กิจดาพัด","กฤษฎาพัฒน์"]
    let t_KAB = ["คันธารัตย์","แก๊ส","แก๊ป","ทิพย์","คันธรัตน์"]
    let t_KSB = ["กอบเกียรติ์","กอล์ฟเกียรติ","กอล์ฟเจี๊ยบ","ก่อเกียรติ","กอล์ฟเกลียด"]
    let t_NKS = ["ได้ก่อน","นึกก่อน","นิก่อน","นิกก่อน"]
    let t_NSN = [""]
    let t_PLS = ["ปัดชญาภรณ์","ปัดเชียร์พร","ปัดเชียร์ยาก่อน","พัทยาพร","ปรัชยาพร","ปัดเชียร์ยาภรณ์","รัชญาพร","ปู","ปรัเชียร์พร","ปัดยพร","ปรัยาภรณ์"]
    let t_PRV = ["ปรวัติ","ประวัติ","ปาราวัด","นรวัฒน์","วรวัฒน์","วราวัด","เปี๊ยก"]
    let t_SSP = ["สถิต","สาธิต","ชาทิศ"]
    let t_SWK = ["สุวัฒชัย","สุวรรณชัย","ถ้วย","ช่วย"]
    let t_TNA = ["ธนภัทร","ธนพัฒน์"]
    let t_NSD = ["นัดทะวุด","นัดทวุฒิ","นัด"]
    
    let r_6181 = ["618 / หนึ่ง","618ทับหนึ่ง"]
    let r_6182 = ["618 / สอง","618ทับสอง"]
    
    
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
        
        speech("สวัสดีค่ะ กดปุ่มไมโครโฟนและพูดเพื่อค้นหาได้เลย")
        
        print("viewDidLoad")
//
//        let position = SCNVector3(0, -1 , -5)
//        let mars = createArrow(at: position,at: "0000")
//        scene.rootNode.addChildNode(mars)
//        sceneView.scene = scene
        
        
        
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
    
    
    @IBAction func micpress(_ sender: Any) {
        
        if (checkstate == 1) {
            speech("ตอนนี้คุณอยู่นอกพื้นที่ให้บริการ กรุณาลองใหม่อีกครั้ง")
        }else{
            
            if audioEngine.isRunning {
                
                audioEngine.stop()
                recognitionRequest?.endAudio()
                recordButton.isEnabled = false
                print("StopRecording")
                recordButton.tintColor = .white
                
                
            } else {
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
                }
                textinput = "nil"
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
        
        print("Start Speech : "+text)
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
        var closestBeacon:CLBeacon
        var rs:NSNumber
        
        /*
         Beacons are categorized by proximity. A beacon can satisfy
         multiple constraints and can be displayed multiple times.
         */
        
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        if (knownBeacons.count > 0) {
            closestBeacon = knownBeacons[0] as CLBeacon
            //                print("proxraw" , closestBeacon.proximity.rawValue)
            rs = closestBeacon.minor
            temp = Int(truncating: rs)
            //                print("proxhash" , closestBeacon.proximity.hashValue)
            let ttzone = closestBeacon.rssi * -1
            //                 print("rssi" , ttzone)
            zoneuse = String(ttzone)
            if (ttzone != 0 ){
                rssisum += ttzone
                numrssi += 1
                
            }
            
        }
        
        if(numrssi == 5){
            rssiavg = rssisum / numrssi
            rssi = temp
            
            
        }
        
        
        
        
        
        
    }
    
    func readDataTeacher()  {
        
        print("Starting GET Data Teacher")
        let url = URL(string:"http://"+ipserver+":8084/WebApplication/teacherjsondata.json")
        URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            do{if error == nil{
                self.arrdatateacher = try JSONDecoder().decode([teacherjsonstruct].self, from: data!)
                print("Get json teacher successful number of list :",self.arrdatateacher.count)
                }
            }catch{
                print("Error in get json data teacher from server")
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
                print("Get json room successful number of list :",self.arrdataroom.count)
                }
            }catch{
                print("Error in get json data teacher from server")
            }
        }.resume()
    }
    
    func postData(textinput:String) {
        
        rssiuse = String(rssi)
        var showtext:String
        
        type = "0"
        let formatter1 = DateFormatter()
        let formatter2 = DateFormatter()
        
        formatter1.dateFormat = "EEEE"
        formatter2.dateFormat = "HH:mm"
        let now = Date()
        let dateString = formatter1.string(from:now)
        datedayuse = dateString
        let dateString2 = formatter2.string(from: now)
        datetimeuse = dateString2
        print("Time Now : ",datedayuse,datetimeuse)
        showtext = textinput
        if type == "0"{
            if textinput.contains("ห้องพัก") {
                find = "1111"
                type = "1"
                print("Has been found = "+find)
                showtext = "ห้องพักอาจารย์"
                
            }
        }
        if type == "0"{
            print("Searching....Room in Database")
            for mainarr in self.arrdataroom{
                
                if textinput.contains(mainarr.room) {
                    find = mainarr.room
                    type = "1"
                    print("Has been found = "+find)
                    showtext = "ห้อง "+mainarr.room
                    break
                }
            }
        }
        if type == "0"{
            print("Searching....Teacher in Database")
            for mainarr in self.arrdatateacher{
                if textinput.contains(mainarr.name) {
                    find = mainarr.aka
                    type = "2"
                    print("Has been found = "+find)
                    showtext = "อาจารย์"+mainarr.name
                    break
                    
                }
            }
        }
        if type == "0"{
            print("Searching....Room synonymin name")
            for mainarr in self.r_6181{
                if textinput.contains(mainarr) {
                    find = "6181"
                    type = "1"
                    showtext = "ห้อง 618/1"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            
            for mainarr in self.r_6182{
                if textinput.contains(mainarr) {
                    find = "6182"
                    type = "1"
                    showtext = "ห้อง 618/2"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            print("Searching....Teacher synonymin name")
            for mainarr in self.t_AWS{
                if textinput.contains(mainarr) {
                    find = "AWS"
                    type = "2"
                    showtext = "อาจารย์อนุสรณ์"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_LPP{
                if textinput.contains(mainarr) {
                    find = "LPP"
                    type = "2"
                    showtext = "อาจารย์ลือพล"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_ENS{
                if textinput.contains(mainarr) {
                    find = "ENS"
                    type = "2"
                    showtext = "อาจารย์เอิญ"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_ADP{
                if textinput.contains(mainarr) {
                    find = "ADP"
                    type = "2"
                    showtext = "อาจารย์อัครา"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_CHR{
                if textinput.contains(mainarr) {
                    find = "CHR"
                    type = "2"
                    showtext = "อาจารย์เฉียบวุฒิ"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_BLT{
                if textinput.contains(mainarr) {
                    find = "BLT"
                    type = "2"
                    showtext = "อาจารย์เบญจพร"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_GDP{
                if textinput.contains(mainarr) {
                    find = "GDP"
                    type = "2"
                    showtext = "อาจารย์กฤดาภัทร"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_KAB{
                if textinput.contains(mainarr) {
                    find = "KAB"
                    type = "2"
                    showtext = "อาจารย์คันธารัตน์"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_KSB{
                if textinput.contains(mainarr) {
                    find = "KSB"
                    type = "2"
                    showtext = "อาจารย์กอบเกียรติ"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_NKS{
                if textinput.contains(mainarr) {
                    find = "NKS"
                    type = "2"
                    showtext = "อาจารย์นิกร"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_NSN{
                if textinput.contains(mainarr) {
                    find = "NSN"
                    type = "2"
                    showtext = "อาจารย์นนทกร"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_PLS{
                if textinput.contains(mainarr) {
                    find = "PLS"
                    type = "2"
                    showtext = "อาจารย์ปรัชญาพร"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_PRV{
                if textinput.contains(mainarr) {
                    find = "PRV"
                    type = "2"
                    showtext = "อาจารย์ปรวัฒน์"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_SSP{
                if textinput.contains(mainarr) {
                    find = "SSP"
                    type = "2"
                    showtext = "อาจารย์สถิตย์"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_SWK{
                if textinput.contains(mainarr) {
                    find = "SWK"
                    type = "2"
                    showtext = "อาจารย์สุวัจชัย"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_TNA{
                if textinput.contains(mainarr) {
                    find = "TNA"
                    type = "2"
                    showtext = "อาจารย์ธนภัทร์"
                    print("Has been found = "+find)
                    break
                }
            }
        }
        if type == "0"{
            for mainarr in self.t_NSD{
                if textinput.contains(mainarr) {
                    find = "NSD"
                    type = "2"
                    showtext = "อาจารย์ณัฐวุฒิ"
                    print("Has been found = "+find)
                    break
                }
            }
            
        }
        
        
        if(textinput == "nil"){
            
            showtext = "ไม่ได้รับข้อความที่คุณค้นหา"
        }
        
        if (type != "0"){
            
            let alert = UIAlertController(title: "คุณต้องการที่จะค้นหา" , message: showtext, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                print("Push : Yes")
//                let url = URL(string:"http://"+self.ipserver+":8084/WebApplication/get.jsp?text="+self.find+"&day="+self.datedayuse+"&timestart="+self.datetimeuse+"&type="+self.type+"&zone="+self.rssiuse+"&rssi="+String(self.rssiavg)+"&dir="+self.dir)
                                               let url = URL(string:"http://"+self.ipserver+":8084/WebApplication/get.jsp?text="+self.find+"&day="+self.datedayuse+"&timestart="+self.datetimeuse+"&type="+self.type+"&zone=2"+"&rssi=75"+"&dir="+self.dir)
                
                
                print(url as Any)
                self.showSpinner(onView: self.view)
                URLSession.shared.dataTask(with: url!) {
                    (data, response, error) in
                    do{if error == nil{
                        
                        self.arrdatarespon = try JSONDecoder().decode([responjsonstruct].self, from: data!)
                        for mainarr in self.arrdatarespon{
                            print(mainarr.r,":",mainarr.x,":",mainarr.y,":",mainarr.z)
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
            print("Not found")
            
            let alert = UIAlertController(title: "ไม่พบข้อความที่คุณค้นหา กรุณาลองใหม่อีกครั้ง", message: showtext, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "try agian", style: .default, handler: { action in
                print("try agian")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func createArrow(at position: SCNVector3,at r:String) -> SCNNode {
        
        // 2
        
        let node = SCNNode()
        let scene:SCNScene
        if(r=="0"){
            scene = SCNScene(named: "art.scnassets/gem.scn")!
        }else{
            scene = SCNScene(named: "art.scnassets/"+r+".scn")!
            //            scene = SCNScene(named: "art.scnassets/diamond.scn")!
        }
        
        
        let nodeArray = scene.rootNode.childNodes
        
        for childNode in nodeArray {
            node.addChildNode(childNode as SCNNode)
        }
        
        // 3
        node.position = position
        node.eulerAngles = SCNVector3(0, 0 , 0)
        // 4
        return node
    }
    func direction()  {
        
        for mainarr in self.arrdatarespon{
            
            let position = SCNVector3(mainarr.x, mainarr.y , mainarr.z)
            
            let mars = createArrow(at: position,at: mainarr.r)
            scene.rootNode.addChildNode(mars)
            sceneView.scene = scene
            
        }
        self.removeSpinner()
        speech("เดินตามลูกศรเพื่อไปยังจุดหมายได้เลย")
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
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
        var tempdir = Double(heading)
        tempdir.round()
        dir = String(tempdir)
        print("Direction of user : "+dir)
        
        
        
    }
    func showSpinner(onView : UIView) {
           let spinnerView = UIView.init(frame: onView.bounds)
           spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
           ai.startAnimating()
           ai.center = spinnerView.center
           
           DispatchQueue.main.async {
               spinnerView.addSubview(ai)
               onView.addSubview(spinnerView)
           }
           
           vSpinner = spinnerView
       }
       
       func removeSpinner() {
           DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
           }
       }
    
    
}

