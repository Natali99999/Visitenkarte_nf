//
//  ViewController.swift
//  Visitenkarte_nf
//
//  Created by Natali Filatov on 02.02.22.
//

import UIKit
import SceneKit
import ARKit
import MessageUI

extension UIImageView {

    func makeRounded() {

        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}


extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }

class ViewController: UIViewController, ARSCNViewDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planeNode:SCNNode!
    var plane:SCNPlane!
    var width:Double!
    var height:Double!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
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
        
        // sms Delegate
        self.navigationController?.isNavigationBarHidden = false
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
   
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            
            width = imageAnchor.referenceImage.physicalSize.width
            height = imageAnchor.referenceImage.physicalSize.height
            
           plane = SCNPlane(
                width: imageAnchor.referenceImage.physicalSize.width,
                height: imageAnchor.referenceImage.physicalSize.height + 60)
           plane.firstMaterial?.diffuse.contents = UIColor(white: 0.4, alpha: 0.8)

           planeNode = SCNNode(geometry: plane)
           planeNode.eulerAngles.x = -.pi / 2
           node.addChildNode(planeNode)
            
           planeNode.addChildNode(createButton(name: "smsButton", x: -30, y:-40))
           planeNode.addChildNode(createButton(name: "phoneButton", x: -10, y:-40))
           planeNode.addChildNode(createButton(name: "mailButton", x: -30, y:-20))
           planeNode.addChildNode(createButton(name: "whatsappButton", x: -10, y:-20))

            planeNode.addChildNode(createButton(name: "homepageButton", x: 15, y:-40))
            planeNode.addChildNode(createButton(name: "githubButton", x: 15, y:-20))
            planeNode.addChildNode(createButton(name: "xingButton", x: 35, y:-40))
            planeNode.addChildNode(createButton(name: "linkedinButton", x: 35, y:-20))

            let planeCard = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            planeCard.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.8)
            let planeCardNode = SCNNode(geometry: planeCard)
            planeCardNode.eulerAngles.x = -.pi / 2
            planeNode.addChildNode(planeCardNode)
            
            if imageAnchor.referenceImage.name == "visitenkarte" {
                print("-----------1")
               
                if let cardScene = SCNScene(named: "art.scnassets/avatar2.scn") {
                    print("-----------2")
                    if let cardNode = cardScene.rootNode.childNodes.first {
                        cardNode.eulerAngles.x = .pi / 2
                        planeCardNode.addChildNode(cardNode)
                    }

                   Timer.scheduledTimer(timeInterval: 1.5, target:self, selector: #selector(updateTimer), userInfo:nil, repeats: false)
                }
                else{
                        print ("Problem load art.scnassets/avatar2.scn")
                }
            }
        }
        
        return node
    }
    @objc func updateTimer() {
       
        
        let Lplane = SCNPlane(
            width: width,
            height: 2*height)
        //Lplane.opacity = 0.1
        let LplaneNode = SCNNode(geometry: Lplane)
      // LplaneNode.eulerAngles.x = -.pi / 2
       LplaneNode.position = SCNVector3(
        width + 5.0,
        50.0,
        -5.0)
        
        Lplane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.4)
       planeNode.addChildNode(LplaneNode)
        
        LplaneNode/*planeCardNode*/.geometry!.firstMaterial!.diffuse.contents = self.createLebenslaufView()
        
    }

    func createLebenslaufView()->UIView{
        let outputView:UIView =  UIView(frame: CGRect(x: 0,y: 0,width: 120,height: 200))
        
        outputView.backgroundColor = //UIColor(white: 1.0, alpha: 0.1)
            UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
       
        if let image = UIImage(named: "natali.jpg") {
            let imageView:UIImageView = UIImageView(
                image: image)
            imageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100);
            imageView.makeRounded()
            outputView.addSubview(imageView)
        }
                                          

        let label = UILabel(frame: CGRect(x: 10, y: 120, width: 200, height: 21))
           // label.center = CGPoint(x: 160, y: 285)
            
        label.textAlignment = .left
        label.text = "Natali Filatov"
        label.textColor = UIColor.blue
        label.font = UIFont(name: "Halvetica", size: 15)
        outputView.addSubview(label)
        
        let label2 = UILabel(frame: CGRect(x: 10, y: 142, width: 150, height: 21))
           // label.center = CGPoint(x: 160, y: 285)
            
        label2.textAlignment = .left
        label2.text = "Software </>"
        label2.textColor = UIColor.blue
        label2.font = UIFont(name: "Halvetica", size: 9)
        outputView.addSubview(label2)
        
        let label3 = UILabel(frame: CGRect(x: 10, y: 160, width: 150, height: 21))
      
        label3.textAlignment = .left
        label3.text = "Entwicklerin"
        label3.textColor = UIColor.blue
        label3.font = UIFont(name: "Halvetica", size: 13)
        outputView.addSubview(label3)

        //self.view.addSubview(snake)
      
        return outputView
   }

    func createOverlayView()->UIView{
        let outputView:UIView =  UIView(frame: CGRect(x: 0,y: 0,width: 100,height: 100))
        
        outputView.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)


        let label = UILabel(frame: CGRect(x: 12, y: 8, width: outputView.frame.size.width-90, height: 50))
        label.text = "Connection error please try again later!!"
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        outputView.addSubview(label)

        //self.view.addSubview(snake)
      
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
    
    func createButton(name:String, x:Double, y:Double)->SCNNode{
         let node = SCNNode()
         let fileName = "art.scnassets/\(name).scn"
      
         if let scene = SCNScene(named: fileName){
             
             print ("----Erfolg load \(fileName)")
             
             if let cubeNode = scene.rootNode.childNode(withName: name, recursively: false){
                print("box ist da")
                 cubeNode.position = SCNVector3(x, y, 5.0)
                 cubeNode.scale = SCNVector3(17.0, 17.0, 2.0)
                 node.addChildNode(cubeNode)
             }
         }
        else{
            print ("Problem load \(fileName)")
        }
         return node
    }
    
    
    //MARK: -  touchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            print("touch")
            
            let touchLocation = touch.location(in: sceneView)
            print (touchLocation)
            guard let result = sceneView.hitTest(touchLocation, options: nil).first else {
               return
             }
            
            //nodeButton = result.node
//            let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
//            let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
//            nodeButton.runAction(SCNAction.rotateBy(
//                x: CGFloat(randomX * 5),
//                y: 0,
//                z: CGFloat(randomZ * 5),
//                duration: 0.5))
            
            if result.node.name == "homepageButton" {
               openLink(urlText: "https://natalifilatov-86aa3.web.app/#/")
 //               node.geometry?.firstMaterial?.diffuse.contents = currentTexture
             }
            else if result.node.name == "phoneButton"{
                callPhone()
            }
            else if result.node.name == "mailButton"{
                sendEmail()
            }
            else if result.node.name == "xingButton"{
                openLink(urlText: "https://www.xing.com/home?redirection=false")
            }
            else if result.node.name == "linkedinButton"{
                openLink(urlText: "https://www.linkedin.com/feed/")
            }
            else if result.node.name == "smsButton"{
                sendSms()
            }
            else if result.node.name == "githubButton"{
                openLink(urlText: "https://github.com/Natali99999")
            }
            else if result.node.name == "whatsappButton"{
                messageViaWhatsApp()
            }
        }
    }
    
    func sendSms(){
        self.showToast(message: "send a message to me", font: .systemFont(ofSize: 12.0))
        let phoneNumber = "015753716643"
        
        if (MFMessageComposeViewController.canSendText()) {
                    let controller = MFMessageComposeViewController()
                    controller.body = "Message Body"
                    controller.recipients = [phoneNumber]
                    controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
           //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
       }

    
    func messageViaWhatsApp(){
        self.showToast(message: "send a message to me via Whatsapp", font: .systemFont(ofSize: 12.0))
        
        let message = "Hallo"
        let queryCharSet = NSCharacterSet.urlQueryAllowed
          
        if let escapedString = message.addingPercentEncoding(withAllowedCharacters: queryCharSet) {
            if let whatsappURL = URL(string: "whatsapp://send?text=\(escapedString)") {
              if UIApplication.shared.canOpenURL(whatsappURL) {
                  UIApplication.shared.open(whatsappURL, options: [: ], completionHandler: nil)
              } else {
                  self.showToast(message: "please install WhatsApp", font: .systemFont(ofSize: 12.0))
                  //debugPrint("please install WhatsApp")
              }
            }
        }
      }
    
    
     func callPhone() {
         self.showToast(message: "call me", font: .systemFont(ofSize: 12.0))
     
         let phoneNumber = "015753716643"
         if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {

         let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
            else {
                 self.showToast(message: "SimCard fehlt", font: .systemFont(ofSize: 12.0))
            }
         }
         else {
             self.showToast(message: "nicht geklappt", font: .systemFont(ofSize: 12.0))
        }
    }
    func openLink(urlText:String) {
        if let url = URL(string: urlText) {
            UIApplication.shared.open(url)
        }
    }
    
    
    func sendEmail() {
        self.showToast(message: "send a mail to me", font: .systemFont(ofSize: 12.0))
        
//        if MFMailComposeViewController.canSendMail() {
//            let mail = MFMailComposeViewController()
//            mail.mailComposeDelegate = self
//            mail.setToRecipients(["natalifilatov@yahoo.de"])
//            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
//
//            present(mail, animated: true)
//        } else {
//            // show failure alert
//        }
    }

//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        controller.dismiss(animated: true)
//    }
  
}

