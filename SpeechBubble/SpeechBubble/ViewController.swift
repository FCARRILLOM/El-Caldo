//
//  ViewController.swift
//  SpeechBubble
//
//  Created by Fernando Carrillo on 8/24/19.
//  Copyright © 2019 FernandoCarrillo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import Speech
import ROGoogleTranslate

class ViewController: UIViewController, ARSCNViewDelegate {
    
    //Speech Recognizer
    let audioEngine = AVAudioEngine()
    var speechRecognizer = SFSpeechRecognizer()
    let speechRequest = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var recording = false;
    
    // AR Nodes
    var rootBubbleNode = SCNNode()
    
    // AR Text
    var textNode = SCNNode()
    var textGeometry = SCNText()
    let textScale = 0.01
    
    // Languages
    let languagesKeys:  [String: String] = ["English" : "en",
                                            "French" : "fr",
                                            "German" : "de",
                                            "Italian" : "it",
                                            "Japanese" : "ja",
                                            "Korean" : "ko",
                                            "Russian" : "ru",
                                            "Spanish" : "es",]
    
    var speechText : String?
    var sourceLanguage: String?
    var targetLanguage: String?
    
    // 3D Arm
    let arms = SCNScene(named: "art.scnassets/arm.dae")!

    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func Stop(_ sender: Any) {
        if(recording) {
            stopRecording()
            recording = false
        }
    }
    
    @IBAction func Start(_ sender: Any) {
        if(!recording) {
            do {
                try startRecording()
                recording = true
            } catch {
                print("Error recording")
            }
        }
    }
    
   
    @IBOutlet weak var DisplayText: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: languagesKeys[UserDefaults.standard.string(forKey: "Input") ?? "English"] ?? "en"))
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/SpeechBubble.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.rootNode.isHidden = true
       
        sourceLanguage = languagesKeys[UserDefaults.standard.string(forKey: "Input") ?? "English"]!
        targetLanguage = languagesKeys[UserDefaults.standard.string(forKey: "Output") ?? "Spanish"]!
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
//        let configuration = ARImageTrackingConfiguration()
        
        // Gets images to be tracked
        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources",
                                                              bundle: nil)
            else {
                print("No images")
                return
            }
        configuration.detectionImages = arImages
//        configuration.trackingImages = arImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Assign root bubble node
        guard let bubbleNode = sceneView.scene.rootNode.childNode(withName: "Bubble",
                                                                  recursively: false)
            else {
                print("No bubble")
                return
        }
        rootBubbleNode = bubbleNode
        
        // Initialize and add text node with placeholder text
        createTextNode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func updateTextRealTime(sentence: String) {
        var newSentence = sentence
        if let spaceIndex = sentence.lastIndex(of: " ") {
            let i = sentence.index(spaceIndex, offsetBy: 1)
            newSentence = String(sentence[i...])
        }
        textGeometry.string = newSentence
        
        textNode.position = SCNVector3(textNode.position.x,
                                       rootBubbleNode.position.y - 0.12, // padding
                                       -rootBubbleNode.position.z) // Allign to left of bubble
    }
    
    func updateTranslatedText(sentence: String) {
        print("Sentence", sentence)
        textNode.position = SCNVector3(textNode.position.x,
                                       rootBubbleNode.position.y - 0.12, // padding
                                        -rootBubbleNode.position.z) // Allign to left of bubble
        let words = sentence.components(separatedBy: " ")
        for word in words {
            DispatchQueue.main.async {
                self.textGeometry.string = word
                if(word == "Hello" || word == "hello") {
                    self.animateHello(armNode: self.arms.rootNode)
                }
            }
            usleep(700000)
        }
    }
    
    // Add text to bubble for the first time
    func createTextNode() {
        textGeometry = SCNText(string: "...", extrusionDepth: 0.02)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.black
        
        textNode.geometry = textGeometry
        textNode.scale = SCNVector3(textScale, textScale, 1)
        textNode.eulerAngles = SCNVector3(0, Float.pi/2, 0)
        
        let parentPos = rootBubbleNode.position
        // Length and height of the text used to center the text in bubble
        let textLength = (textNode.geometry?.boundingBox.max.x)! * Float(textScale)
        let textHeight = (textNode.geometry?.boundingBox.max.y)! * Float(textScale)
        
        textNode.position = SCNVector3(parentPos.x + rootBubbleNode.boundingBox.max.x, // Overlap over bubble
                                       parentPos.y - textHeight/2, // Center vertically
                                       parentPos.z + textLength/2) // Center horiztonally
        
        print(rootBubbleNode.boundingBox)
        
        rootBubbleNode.addChildNode(textNode)
    }
    
    // Updates variable "speechText" with the speech recognized
    private func startRecording() throws {
        
        //microphone
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.speechRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: speechRequest) {
            [unowned self]
            (result, _) in
            if let transcription = result?.bestTranscription {
                self.speechText = transcription.formattedString

                if let texto = self.speechText{
                    // Show sentence real time if it's not being translated
                    if(self.sourceLanguage == self.targetLanguage) {
                        self.updateTextRealTime(sentence: texto)
                    }
                }
            }
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        speechRequest.endAudio()
        recognitionTask?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
        if(sourceLanguage != targetLanguage) {
            print("Input text:",  self.speechText)
            if(UserDefaults.standard.string(forKey: "Input") != UserDefaults.standard.string(forKey: "Output")){
                Translate(src: languagesKeys[UserDefaults.standard.string(forKey: "Input") ?? "English"]!, tgt: languagesKeys[UserDefaults.standard.string(forKey: "Output") ?? "Spanish"]!, txt: self.speechText ?? "")
            }
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
    
    // Adds node when anchor is found
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARImageAnchor else { return }
        sceneView.scene.rootNode.isHidden = false
        print("QRCode found")
        guard let bubbleNode = sceneView.scene.rootNode.childNode(withName: "Bubble",
                                                                  recursively: false) else { return }
        // 0.22, 0, -0.38
        bubbleNode.position = SCNVector3(0.22, 0, -0.38)
        node.addChildNode(bubbleNode)
        
        let armNode = arms.rootNode
        armNode.eulerAngles = SCNVector3(-Float.pi/2, 0, Float.pi)
        armNode.scale = SCNVector3(0.1, 0.1, 0.1)
        armNode.position = SCNVector3(0, 0, 0.15)
        node.addChildNode(armNode)
        print("Adding bubble")
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
    
    

    func Translate(src: String,tgt: String,txt: String ){
        let params = ROGoogleTranslateParams(source: src,
                                             target: tgt,
                                             text:   txt)
        
        let translator = ROGoogleTranslate()
        
            translator.translate(params: params) { (result) in
                print("Translating text...")
                self.updateTranslatedText(sentence: result)
            }
        
    }
    
    // 3D ARM
    func animateHello(armNode: SCNNode) {
        var helloAnimation = CAAnimation()
        helloAnimation = CAAnimation.animationWithSceneNamed("art.scnassets/armHello")!
        helloAnimation.fadeInDuration = 0.3
        helloAnimation.fadeOutDuration = 0.3
        helloAnimation.repeatCount = 1
        armNode.addAnimation(helloAnimation, forKey: "hello")
    }
}

// MARK: CoreAnimation

extension CAAnimation {
    class func animationWithSceneNamed(_ name: String) -> CAAnimation? {
        var animation: CAAnimation?
        if let scene = SCNScene(named: name) {
            scene.rootNode.enumerateChildNodes({ (child, stop) in
                if child.animationKeys.count > 0 {
                    animation = child.animation(forKey: child.animationKeys.first!)
                    stop.initialize(to: true)
                }
            })
        }
        return animation
    }
}
