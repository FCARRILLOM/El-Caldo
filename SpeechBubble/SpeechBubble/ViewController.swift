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
    let speechRecognizer = SFSpeechRecognizer()
    let speechRequest = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    var speechText : String?

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
                //if let texto = self.speechText{
                  //  print(texto)
                //}
                //Translates the text
                
            }
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        speechRequest.endAudio()
        recognitionTask?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
        self.speechText = ""
        
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
    
    
    
    func Translate(src: String,tgt: String,txt: String)->String?{
       
        
        let params = ROGoogleTranslateParams(source: src,
                                             target: tgt,
                                             text:   txt)
        var text : String?
        let translator = ROGoogleTranslate()
        
        translator.translate(params: params) { (result) in
             text = result;
        }
        return text
    }
}
