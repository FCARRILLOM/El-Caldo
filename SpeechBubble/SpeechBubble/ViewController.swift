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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/SpeechBubble.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.rootNode.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // Gets images to be tracked
        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources",
                                                              bundle: nil)
            else {
                print("No images")
                return
            }
        configuration.trackingImages = arImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Root bubble node
        guard let bubbleNode = sceneView.scene.rootNode.childNode(withName: "Bubble",
                                                                  recursively: false)
            else {
                print("No bubble")
                return
        }
        addTextToBubble(parentNode: bubbleNode)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Add text to bubble for the first time
    func addTextToBubble(parentNode: SCNNode) {
        let parentPos = parentNode.position
        let textScale = 0.009
        
        let textGeometry = SCNText(string: "...", extrusionDepth: 0.02)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.black
                
        // Length and height used to center text in bubble
        let textLength = textGeometry.boundingBox.max.x * Float(textScale)
        let textHeight = textGeometry.boundingBox.max.y * Float(textScale)
        
        let textNode = SCNNode()
        textNode.geometry = textGeometry
        textNode.position = SCNVector3(parentPos.x + parentNode.boundingBox.max.x,
                                       parentPos.y - textHeight/2,
                                       parentPos.z + textLength/2)
        textNode.scale = SCNVector3(textScale, textScale, 1)
        textNode.eulerAngles = SCNVector3(0, Float.pi/2, 0)
        
        parentNode.addChildNode(textNode)
    }
    
    // Updates bubble with text
    func updateText() {
        
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
        node.addChildNode(bubbleNode)
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
}
