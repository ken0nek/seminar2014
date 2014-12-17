//
//  GameViewController.swift
//  seminar2014
//
//  Created by Ken Tominaga on 11/26/14.
//  Copyright (c) 2014 Ken Tominaga. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import Alamofire

class GameViewController: UIViewController, SRWebSocketDelegate {
    
    // var sceneView: SCNView?
    var scene: SCNScene?
    var arrowImageView: UIImageView?
    let w: CGFloat = 320.0
    let h: CGFloat = 568.0
    // let IPADDRESS = "192.168.149.102"
    let IPADDRESS = "172.16.0.2"
    let PORT = "443"
    
    var webSocketInstance: SRWebSocket = SRWebSocket()
    
    var robo: SCNNode?
    var rootBone: SCNNode?
    var upperBone: SCNNode?
    var foreBone: SCNNode?
    var handBone: SCNNode?
    var ikc: SCNIKConstraint?
    
    var label1: UILabel = UILabel(frame: CGRectMake(40, 40, 80, 40))
    var label2: UILabel = UILabel(frame: CGRectMake(40, 80, 80, 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scene = SCNScene(named: "Armv0.dae")
        
        let camera = SCNNode()
        camera.camera = SCNCamera()
        self.scene?.rootNode.addChildNode(camera)
        camera.position = SCNVector3(x: 0, y: 0, z: 15)
        
        robo = self.scene!.rootNode.childNodeWithName("Robo", recursively: true)!
        robo?.rotation = SCNVector4Make(0, 0, 1, Float(M_PI)/2.0)
        rootBone = robo?.childNodeWithName("RootBone", recursively: true)!
        upperBone = robo?.childNodeWithName("UpperBone", recursively: true)!
        foreBone = robo?.childNodeWithName("ForeBone", recursively: true)!
        handBone = robo?.childNodeWithName("HandBone", recursively: true)!
        
        ikc = SCNIKConstraint.inverseKinematicsConstraintWithChainRootNode(rootBone!)
        ikc?.influenceFactor = 1.0
        let maxA: CGFloat = CGFloat(M_PI) * 3600.0 / 180.0
        let maxB: CGFloat = CGFloat(M_PI) * 7200.0 / 180.0
        ikc?.setMaxAllowedRotationAngle(maxA, forJoint: upperBone!)
        ikc?.setMaxAllowedRotationAngle(maxB, forJoint: foreBone!)
        
        handBone?.constraints = [ikc!]
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(0.0)
        ikc?.targetPosition = self.scene!.rootNode.convertPosition(SCNVector3(x: 0, y: -4.2, z: 0), toNode: nil)
        SCNTransaction.commit()
        
        let sceneView = self.view as SCNView
        sceneView.scene = self.scene
        sceneView.backgroundColor = UIColor.whiteColor()
        
//        let box = SCNBox(width: 9.4, height: 16.7, length: 1, chamferRadius: 0)
//        box.firstMaterial?.diffuse.contents = UIColor.redColor()
//        let boxNode = SCNNode(geometry: box)
//        self.scene?.rootNode.addChildNode(boxNode)
        
        let url = NSURL(string: "ws://\(IPADDRESS):\(PORT)")!
        webSocketInstance = SRWebSocket(URLRequest: NSURLRequest(URL: url))!
        webSocketInstance.delegate = self
        webSocketInstance.open()
        
        label1.text = "radian1"
        label1.textColor = UIColor.blackColor()
        self.view.addSubview(label1)
        
        label2.text = "radian2"
        label2.textColor = UIColor.blackColor()
        self.view.addSubview(label2)
    }
    
    // MARK: SRWebSocketDelegate
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        println("socket open!")
        
//        let upperBone = self.scene!.rootNode.childNodeWithName("UpperBone", recursively: true)!
//        let foreBone = self.scene!.rootNode.childNodeWithName("ForeBone", recursively: true)!
//        
//        println(upperBone.rotation)
//        println(foreBone.rotation)
        
//        let radian1 = 0
//        let radian2 = 0
//        
//        let data = "{\"radian1\":\"\(radian1)\", \"radian2\":\"\(radian2)\"}"
//        
//        webSocket.send(data)
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        println("data received")
    }
    
    func sendData(radian1: Float, _ radian2: Float) {
        println("radian1 : \(radian1)\nradian2 : \(radian2)")
        
        label1.text = "\(radian1)"
        label2.text = "\(radian2)"
        
        if webSocketInstance.readyState.value != SR_OPEN.value {
            return
        }
        
        println("send!!!!!")
        
        let data = "{\"radian1\":\"\(radian1)\", \"radian2\":\"\(radian2)\"}"
        
        webSocketInstance.send(data)
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        let p = touches.anyObject()!.locationInView(self.view)
        println("touch location : \(p)") // total arm length :  226, buttom : 160, 410, top : 160, 184
        
        let xTarget = Float((p.x - 160) * 9.4 / 320)
        let yTarget = -4.2 + -Float((p.y - 410) * 16.7 / 568)
        
        println("x : \(xTarget), y : \(yTarget)")
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(0.0)
        // ikc?.targetPosition = self.scene!.rootNode.convertPosition(SCNVector3(x: xTarget, y: yTarget, z: 0), toNode: nil)
        ikc?.targetPosition = SCNVector3Make(xTarget, yTarget, 0)
        SCNTransaction.commit()
    
//        println("upper euler : \(upperBone?.presentationNode().eulerAngles.x), \(upperBone?.presentationNode().eulerAngles.y), \(upperBone?.presentationNode().eulerAngles.z)")
//        println("upper rotation : \(upperBone?.presentationNode().rotation.x), \(upperBone?.presentationNode().rotation.y), \(upperBone?.presentationNode().rotation.z), \(upperBone?.presentationNode().rotation.w)")
//        
//        println("fore eular : \(foreBone?.presentationNode().eulerAngles.x), \(foreBone?.presentationNode().eulerAngles.y), \(foreBone?.presentationNode().eulerAngles.z)")
//        println("fore rotation : \(foreBone?.presentationNode().rotation.x), \(foreBone?.presentationNode().rotation.y), \(foreBone?.presentationNode().rotation.z), \(foreBone?.presentationNode().rotation.w)")
        
        sendData(-upperBone!.presentationNode().eulerAngles.x, -foreBone!.presentationNode().eulerAngles.x)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
