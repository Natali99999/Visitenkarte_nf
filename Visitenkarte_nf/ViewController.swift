//
//  ViewController.swift
//  Visitenkarte_nf
//
//  Created by Natali Filatov on 02.02.22.
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
        sceneView.autoenablesDefaultLighting = true
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
       let configuration = ARImageTrackingConfiguration()
       // let configuration = ARWorldTrackingConfiguration()
        
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Visitenkarte", bundle: Bundle.main) {
            
           // configuration.detectionImages = [ imageToTrack as! ARReferenceImage]
          //  configuration.planeDetection  = .horizontal

           configuration.trackingImages = imageToTrack
            configuration.maximumNumberOfTrackedImages = 1
            print("Image Successfully Added")
       }
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
   
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            
            let plane = SCNPlane(
                width: imageAnchor.referenceImage.physicalSize.width + 20,
                height: imageAnchor.referenceImage.physicalSize.height + 60)
            plane.firstMaterial?.diffuse.contents = UIColor(white: 0.4, alpha: 0.8)

           let planeNode = SCNNode(geometry: plane)
               // self.create3dObject(name:"art.scnassets/Mushroom.scn")
           planeNode.eulerAngles.x = -.pi / 2
           node.addChildNode(planeNode)
            
            planeNode.addChildNode(createButton(name: "art.scnassets/homeButton.scn", x: -30))
            planeNode.addChildNode(createButton(name: "art.scnassets/phoneButton.scn", x: -10))
            planeNode.addChildNode(createButton(name: "art.scnassets/mailButton.scn", x: 10))
            
//            let cube = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.05)
//            let material = SCNMaterial()
//            material.diffuse.contents = UIColor.red
//            cube.materials = [material]
//            let nodeCube = SCNNode()
//            nodeCube.position = SCNVector3(0.1, 0.1, 0.1)
//            nodeCube.geometry = cube
//            planeNode.addChildNode(nodeCube)
            
            let planeCard = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            planeCard.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.8)
            let planeCardNode = SCNNode(geometry: planeCard)
            planeCardNode.eulerAngles.x = -.pi / 2
            planeNode.addChildNode(planeCardNode)
            
            if imageAnchor.referenceImage.name == "visitenkarte" {
                if let cardScene = SCNScene(named: "art.scnassets/avatar2.scn") {
                     if let cardNode = cardScene.rootNode.childNodes.first {
                        cardNode.eulerAngles.x = .pi / 2
                        planeCardNode.addChildNode(cardNode)
                    }

                    //planeNode.opacity = 0.5
                    /*planeNode*/planeCardNode.geometry!.firstMaterial!.diffuse.contents = self.createOverlayView()
                }
            }
        }
        
        return node
    }


    func createOverlayView()->UIView{
        let outputView:UIView =  UIView(frame: CGRect(x: 0,y: 0,width: 10,height: 100))
        outputView.backgroundColor = UIColor(white: 1, alpha: 0.5)
       return outputView
   }

    func create3dObject(name:String)->SCNNode{
        print("create3dObject \(name)")
        let node = SCNNode()
        
        if let scene = SCNScene(named: name) {
            for child in scene.rootNode.childNodes {
                node.addChildNode(child)
            }
        }
        // Set up some properties
       // node.scale = SCNVector3(0.5, 0.5, 0.5)
        //node.scale = SCNVector3(0.0009, 0.0009, 0.0009)
        // Add the node to the scene
        //sceneView.scene.rootNode.addChildNode(node)
        return node
    }
    
    func createButton(name:String, x:Double)->SCNNode{
         let node = SCNNode()
        
         if let scene = SCNScene(named: name){
            
             if let cubeNode = scene.rootNode.childNode(withName: "box", recursively: false) {
                print("box ist da")
                 cubeNode.position = SCNVector3(x, -40.0, 5.0)
                 cubeNode.scale = SCNVector3(17.0, 17.0, 2.0)
                
                //        sphere.materials = [material]
                 node.addChildNode(cubeNode)
             }
             
         }
         return node
    }
    
    
    //MARK: - Avatar rendering methods
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode{
        let plane = SCNPlane(
            width: CGFloat(planeAnchor.extent.x),
            height: CGFloat(planeAnchor.extent.z))
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(
            planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        planeNode.geometry = plane
        return planeNode
    }
    
    //MARK: -  Rendering Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            print("touch")
            
            let touchLocation = touch.location(in: sceneView)
            print (touchLocation)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if !results.isEmpty {
                
                if let hitResult = results.first {
                    print (hitResult)
                    // addDice(atLocation: hitResult)
                }
            }
        }
    }
    
    
  
}
