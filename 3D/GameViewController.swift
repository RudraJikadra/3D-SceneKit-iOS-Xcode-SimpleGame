//
//  GameViewController.swift
//  3D
//
//  Created by Rudra Jikadra on 14/12/17.
//  Copyright © 2017 Rudra Jikadra. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    var gameView : SCNView!
    var gameScene : SCNScene!
    var cameraNode : SCNNode!
    var targetCreationTime : TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initScene()
        initCamera()
        
    }
    
    func createTarget(){
        let geometry:SCNGeometry = SCNPyramid(width: 1.2, height: 1.2, length: 1.2)
        
        let randomColor = arc4random_uniform(2) == 0 ? UIColor(red : 0, green: 0, blue: 255, alpha: 0.9) : UIColor(red: 255, green: 0, blue: 0, alpha: 0.9)
        geometry.materials.first?.diffuse.contents = randomColor
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if randomColor == UIColor(red : 0, green: 0, blue: 255, alpha: 0.9) {
            geometryNode.name = "good"
        }
        else
        {
            geometryNode.name = "bad"
        }
        
        gameScene.rootNode.addChildNode(geometryNode)
        
        let randomDir:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let force = SCNVector3Make(randomDir, 15, 0)
        
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3Make(0.05, 0.05, 0.05), asImpulse: true)
    }
    
    func initView() {
        gameView = self.view as! SCNView
        gameView.allowsCameraControl = false
        gameView.autoenablesDefaultLighting = true
        
        gameView.delegate = self
    }
    
    func initScene(){
        gameScene = SCNScene()
        gameView.scene = gameScene
        
        gameView.isPlaying = true
    }
    
    func initCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0, y: 6, z: 10)
        
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime {
            createTarget()
            targetCreationTime = time + 0.6
        }
        
        cleanUp()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        let location = touch.location(in: gameView)
        
        let hitList = gameView.hitTest(location, options: nil)
        
        if let hitObject = hitList.first {
            let node = hitObject.node
            
            if node.name == "good" {
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.white
            }else{
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.red
            }
        }
    }
    
    func cleanUp(){
        for node in gameScene.rootNode.childNodes {
            if node.presentation.position.y < -10 {
                node.removeFromParentNode()
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
