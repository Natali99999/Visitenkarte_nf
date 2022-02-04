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

struct SceneData {
    let name:String
    let x:Double
    let y:Double
}

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

class ViewController: UIViewController, ARSCNViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planeNode:SCNNode!
    var plane:SCNPlane!
    var width:Double!
    var height:Double!
    var profilNode:SCNNode!
    
    var buttons = [SceneData]()
    var experiences = [SceneData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        experiences.append(SceneData(name: "VisualC++", x:-25, y: -60))
        experiences.append(SceneData(name: "Qt", x:10, y: -60))
        experiences.append(SceneData(name: "Java", x:-25, y: -80))
        experiences.append(SceneData(name: "JavaEE", x:2, y: -80))
        experiences.append(SceneData(name: "SpringBoot", x:35, y: -80))
        experiences.append(SceneData(name: "HtmlCssJS", x:-15, y: -100))
        experiences.append(SceneData(name: "Asure", x:25, y: -100))
        experiences.append(SceneData(name: "Aws", x:55, y: -100))
        experiences.append(SceneData(name: "Swift", x:-25, y: -120))
        experiences.append(SceneData(name: "Flutter", x:2, y: -120))
        experiences.append(SceneData(name: "React", x:35, y: -120))
        
        buttons.append(SceneData(name: "smsButton", x: -30, y:-40))
        buttons.append(SceneData(name: "phoneButton", x: -10, y:-40))
        buttons.append(SceneData(name: "mailButton", x: -30, y:-20))
        buttons.append(SceneData(name: "whatsappButton", x: -10, y:-20))
        buttons.append(SceneData(name: "homepageButton", x: 15, y:-40))
        buttons.append(SceneData(name: "githubButton", x: 15, y:-20))
        buttons.append(SceneData(name: "xingButton", x: 35, y:-40))
        buttons.append(SceneData(name: "linkedinButton", x: 35, y:-20))
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       let configuration = ARImageTrackingConfiguration()
       
       if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Visitenkarte", bundle: Bundle.main) {
            configuration.trackingImages = imageToTrack
            configuration.maximumNumberOfTrackedImages = 1
           // print("Image Successfully Added")
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
            
            planeNode = createPlaneNode()
            node.addChildNode(planeNode)
            
            let cardNode = createCardNode()
            planeNode.addChildNode(cardNode)
            
            if imageAnchor.referenceImage.name == "visitenkarte" {
                 if let cardScene = SCNScene(named: "art.scnassets/avatar2.scn") {
                    
                     // Show 3D Model "avatar"
                    if let avatarNode = cardScene.rootNode.childNodes.first {
                        avatarNode.eulerAngles.x = .pi / 2
                        cardNode.addChildNode(avatarNode)
                    }

                    createProfilView()
                    showExperiences()
                }
                else{
                    print ("Problem load art.scnassets/avatar2.scn")
                }
            }
        }
        
        return node
    }
    
    func createCardNode() -> SCNNode{
        let planeCard = SCNPlane(width: width, height: height)
        planeCard.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.8)
        let planeCardNode = SCNNode(geometry: planeCard)
        planeCardNode.eulerAngles.x = -.pi / 2
        
        return planeCardNode
    }
    
    func createPlaneNode() -> SCNNode{
        plane = SCNPlane(width: width, height: height + 60)
        plane.firstMaterial?.diffuse.contents = UIColor(red: 0.07, green: 0.40, blue: 0.19, alpha: 0.95)
        planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        for button in buttons {
            planeNode.addChildNode(createSceneOb(name: button.name, x: button.x, y:button.y))
        }
        
        return planeNode
    }
    
    func createProfilView(){
      let profilPlane = SCNPlane( width: self.width, height: 2*self.height-10)
       profilNode = SCNNode(geometry: profilPlane)
       profilNode.position = SCNVector3(width + 5.0,  50.0, 7.0)
       planeNode.addChildNode(profilNode)
       profilNode.geometry!.firstMaterial!.diffuse.contents = DrawProfil()
    }
    
    func roll(node: SCNNode){
        let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 4))
        node.runAction(action)
    }
  
    @objc func showExperiences() {
        for expirience in experiences {
             let expirienceNode:SCNNode = createSceneOb(name: expirience.name, x: expirience.x, y: expirience.y)
             profilNode.addChildNode(expirienceNode)
             roll(node: expirienceNode)
         }
    }

    func DrawProfil()->UIView{
     
        let outputView:UIView =  UIView(frame: CGRect(x: 0, y: 0, width: 120, height:200))
        
        outputView.backgroundColor =
        UIColor(red: 0.07, green: 0.40, blue: 0.19, alpha: 0.8)
      
        if let image = UIImage(named: K.profilImage) {
            let imageView:UIImageView = UIImageView(
                image: image)
            imageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100);
            imageView.makeRounded()
            outputView.addSubview(imageView)
        }
        
        let label = UILabel(frame: CGRect(x: 10, y: 120, width: 200, height: 21))
        label.textAlignment = .left
        label.text = "\(K.profilVorname) \(K.profilName)"
        label.textColor = UIColor.white
        label.font = UIFont(name: "Halvetica", size: 15)
        outputView.addSubview(label)
        
        let label2 = UILabel(frame: CGRect(x: 10, y: 142, width: 150, height: 18))
        label2.textAlignment = .left
        label2.text = (K.profilDesc)
        label2.textColor = UIColor.white
        label2.font = UIFont(name: "Halvetica", size: 9)
        outputView.addSubview(label2)
        
        let label3 = UILabel(frame: CGRect(x: 10, y: 160, width: 150, height: 18))
        label3.textAlignment = .left
        label3.text = K.profilDesc2
        label3.textColor = UIColor.white
        label3.font = UIFont(name: "Halvetica", size: 9)
        outputView.addSubview(label3)
  
        return outputView
   }

//    func createOverlayView()->UIView{
//        let outputView:UIView =  UIView(frame: CGRect(x: 0,y: 0,width: 100,height: 100))
//
//        outputView.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
//
//        let label = UILabel(frame: CGRect(x: 12, y: 8, width: outputView.frame.size.width-90, height: 50))
//        label.text = "Connection error please try again later!!"
//        label.textColor = UIColor.white
//        label.numberOfLines = 0
//        label.font = UIFont.systemFont(ofSize: 14)
//        outputView.addSubview(label)
//
//        return outputView
//   }

    func createSceneOb(name:String, x:Double, y:Double)->SCNNode{
         let node = SCNNode()
         let fileName = "art.scnassets/\(name).scn"
      
         if let scene = SCNScene(named: fileName){
             if let objNode = scene.rootNode.childNode(withName: name, recursively: false){
                 objNode.position = SCNVector3(x, y, 5.0)
                 objNode.scale = SCNVector3(17.0, 17.0, 2.0)
                 node.addChildNode(objNode)
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
            let touchLocation = touch.location(in: sceneView)
           
            guard let result = sceneView.hitTest(touchLocation, options: nil).first else {
               return
            }

            if result.node.name == "homepageButton" {
               openLink(urlText: "https://natalifilatov-86aa3.web.app/#/")
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
        
        if (MFMessageComposeViewController.canSendText()) {
                    let controller = MFMessageComposeViewController()
                    controller.body = "Message Body"
            controller.recipients = [K.phoneNumber]
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
        
        let message = K.profilMessage
        let queryCharSet = NSCharacterSet.urlQueryAllowed
          
        if let escapedString = message.addingPercentEncoding(withAllowedCharacters: queryCharSet) {
            if let whatsappURL = URL(string: "whatsapp://send?text=\(escapedString)") {
              if UIApplication.shared.canOpenURL(whatsappURL) {
                  UIApplication.shared.open(whatsappURL, options: [: ], completionHandler: nil)
              } else {
                self.showToast(message: "please install WhatsApp", font: .systemFont(ofSize: 12.0))
               }
            }
        }
      }
    
     func callPhone() {
         self.showToast(message: "call me", font: .systemFont(ofSize: 12.0))
         
         if let phoneCallURL = URL(string: "tel://\(K.phoneNumber)") {

         let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
            else {
                 self.showToast(message: "SimCard fehlt", font: .systemFont(ofSize: 12.0))
            }
         }
         else {
             self.showToast(message: "call a phone number failure", font: .systemFont(ofSize: 12.0))
        }
    }
    func openLink(urlText:String) {
        if let url = URL(string: urlText) {
            UIApplication.shared.open(url)
        }
    }
    
    func sendEmail() {
        self.showToast(message: "send a mail to me", font: .systemFont(ofSize: 12.0))
          
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([K.profilEmail])
            mail.setMessageBody("<p>\(K.profilMessage)</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            self.showToast(message: "send a mail failure", font: .systemFont(ofSize: 12.0))
          }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
  
}

