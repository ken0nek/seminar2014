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
    
    var scene: SCNScene?
    var arrowImageView: UIImageView?
    let w: CGFloat = 320.0
    let h: CGFloat = 568.0
    // let IPADDRESS = "192.168.149.102"
    let IPADDRESS = "172.16.0.2"
    let PORT = "443"
    
    var webSocketInstance: SRWebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        
        
        // setupArrow()
        
        setupScene()
        setupCamera()
        setupArms()
        
        let url = NSURL(string: "ws://\(IPADDRESS):\(PORT)")!
        println(url)
        webSocketInstance = SRWebSocket(URLRequest: NSURLRequest(URL: url))
        webSocketInstance?.delegate = self
        webSocketInstance?.open()
        // Alamofire.request(.POST, url)
    }
    
    // MARK: SRWebSocketDelegate
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        let parameters = [
            "radian1": 20 * M_PI / 180,
            "radian2": 30 * M_PI / 180
        ]
        
        let data = "{\"radian1\":\"\(20 * M_PI / 180)\", \"radian2\":\"\(30 * M_PI / 180)\"}"
        
        webSocket.send(data)

    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        println("data received")
    }
    
    func setupScene() {
        let sv = SCNView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        sv.scene = SCNScene()
        sv.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(sv)
        
        self.scene = sv.scene
    }
    
    func setupArms() {
        let anchor = SCNSphere(radius: 5)
        anchor.firstMaterial?.diffuse.contents = UIColor.blackColor()
        let anchorNode = SCNNode(geometry: anchor)
        anchorNode.name = "anchor"
        anchorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        anchorNode.physicsBody = SCNPhysicsBody.kinematicBody()
        
        let arm1 = SCNCylinder(radius: 5, height: 20)
        arm1.firstMaterial?.diffuse.contents = UIColor.blueColor()
        let armNode1 = SCNNode(geometry: arm1)
        armNode1.name = "arm1"
        armNode1.position = SCNVector3(x: 0, y: -10, z: 0)
        armNode1.physicsBody = SCNPhysicsBody.kinematicBody()
        
        let arm2 = SCNCylinder(radius: 5, height: 20)
        arm2.firstMaterial?.diffuse.contents = UIColor.redColor()
        let armNode2 = SCNNode(geometry: arm2)
        armNode2.name = "arm2"
        armNode2.position = SCNVector3(x: 0, y: -20, z: 0)
        armNode2.physicsBody = SCNPhysicsBody.kinematicBody()
        
        let hand = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0)
        hand.firstMaterial?.diffuse.contents = UIColor.yellowColor()
        let handNode = SCNNode(geometry: hand)
        handNode.name = "hand"
        handNode.position = SCNVector3(x: 0, y: -15, z: 0)
        handNode.physicsBody = SCNPhysicsBody.kinematicBody()
        
        // let j1 = SCNPhysicsBallSocketJoint(
        
        self.scene?.rootNode.addChildNode(anchorNode)
        anchorNode.addChildNode(armNode1)
        armNode1.addChildNode(armNode2)
        armNode2.addChildNode(handNode)
        
//        let ik = SCNIKConstraint.inverseKinematicsConstraintWithChainRootNode(anchorNode)
//        handNode.constraints = [ik]
//        SCNTransaction.setAnimationDuration(5.0)
//        ik.targetPosition = SCNVector3(x: 0, y: 50, z: 0)
    }
    
    func setupCamera() {
        let camera = SCNNode()
        camera.camera = SCNCamera()
//        camera.position = SCNVector3(x: 0, y: 20, z: 100)
//        camera.rotation = SCNVector4(x: 0, y: 0, z: 0, w: -0.1)
        camera.position = SCNVector3(x: 15, y: 0, z: 100)
        camera.rotation = SCNVector4(x: 0, y: 0, z: 0, w: -0.1)
        self.scene?.rootNode.addChildNode(camera)
    }
    
//    // MARK: arrow
//    
//    func setupArrow() {
//        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: w, height: h - w))
//        baseView.backgroundColor = UIColor.yellowColor()
//        baseView.userInteractionEnabled = true
//        
//        arrowImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 50), size: CGSize(width: w, height: (h - w) / 2)))
//        arrowImageView?.image = UIImage(named: "arrow")
//        arrowImageView?.userInteractionEnabled = true
//        arrowImageView?.contentMode = UIViewContentMode.ScaleAspectFit
//        baseView.addSubview(arrowImageView!)
//        
//        let pgr = UIPanGestureRecognizer(target: self, action: Selector("didDrag:"))
//        baseView.addGestureRecognizer(pgr)
//        
//        self.view.addSubview(baseView)
//    }
//    
//    func didDrag(pgr: UIPanGestureRecognizer) {
//        let targetView = pgr.view!
//        let position = pgr.locationInView(targetView)
//        
//        let dx = position.x - targetView.center.x
//        let dy = position.y - targetView.frame.origin.y
//        let angle = -atan(dx / dy)
//        arrowImageView?.transform = CGAffineTransformMakeRotation(angle)
//    }
    
    var count = 0
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let handNode = self.scene!.rootNode.childNodeWithName("hand", recursively: true)
        let ik = SCNIKConstraint.inverseKinematicsConstraintWithChainRootNode(self.scene!.rootNode)
        
        ++count
        
        println(touches.anyObject())
        
        SCNTransaction.setAnimationDuration(5.0)
        if count % 2  == 0 {
            ik.targetPosition = SCNVector3(x: 50, y: 0, z: 0)
        } else {
            ik.targetPosition = SCNVector3(x: 35, y: 20, z: 0)
        }
        
        handNode?.constraints = [ik]
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
