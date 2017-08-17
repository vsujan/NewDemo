//
//  ViewController.swift
//  NewDemo
//
//  Created by Sujan Vaidya on 8/16/17.
//  Copyright © 2017 Sujan Vaidya. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {
  @IBOutlet weak var sceneView: ARSCNView!
  let scene = SCNScene()
  var anchors: [ARPlaneAnchor] = []
  var planeHeight: CGFloat = 0.01
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.delegate = self
    sceneView.showsStatistics = true
    self.sceneView.scene = scene
    self.sceneView.autoenablesDefaultLighting = true
    self.sceneView.debugOptions  = [.showConstraints, .showLightExtents, ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    self.sceneView.showsStatistics = true
    self.sceneView.automaticallyUpdatesLighting = true
    setSessionConfiguration()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  var configuration = ARWorldTrackingConfiguration()
  
  func setSessionConfiguration() {
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration, options: [.resetTracking])
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: sceneView)
    let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
    if hitResults.count > 0 {
      let result: ARHitTestResult = hitResults.first!
      
      let newLocation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
      addCube(location: newLocation)
    }
  }
  
  func addCube(location: SCNVector3) {
    let dimension: CGFloat = 3
    var cubePosition = location
    cubePosition.y -= Float(dimension) / 2
    let cube = SCNBox(width: dimension / 30, height: dimension, length: dimension / 30, chamferRadius: 0)
    let cubeNode = SCNNode(geometry: cube)
    let img1 = UIImage(named: "one.png")
    let img2 = UIImage(named: "two.png")
    let img3 = UIImage(named: "three.png")
    let img4 = UIImage(named: "four.png")
    let img5 = UIImage(named: "five.png")
    let img6 = UIImage(named: "six.png")
    let material1 = SCNMaterial()
    let material2 = SCNMaterial()
    let material3 = SCNMaterial()
    let material4 = SCNMaterial()
    let material5 = SCNMaterial()
    let material6 = SCNMaterial()
    material1.diffuse.contents = img1
    material2.diffuse.contents = img2
    material3.diffuse.contents = img3
    material4.diffuse.contents = img4
    material5.diffuse.contents = img5
    material6.diffuse.contents = img6
    cube.materials = [material1, material2, material3, material4, material5, material6]
    cubeNode.position = cubePosition
//    cubeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: cube, options: nil))
    sceneView.scene.rootNode.addChildNode(cubeNode)
  }
  
}

extension ViewController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    var node:  SCNNode?
    if let planeAnchor = anchor as? ARPlaneAnchor {
      let rotationX = anchor.transform.columns.1.y
      var planeType = "Floor"
      if rotationX < 0 {
        planeType = "Ceiling"
      }
      print ("plane type is: ", planeType)
      node = SCNNode()
      let planeGeometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: planeHeight, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0.0)
      planeGeometry.firstMaterial?.diffuse.contents = UIColor.green
      planeGeometry.firstMaterial?.specular.contents = UIColor.white
      let planeNode = SCNNode(geometry: planeGeometry)
      planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight / 2), planeAnchor.center.z)
      planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
      node?.addChildNode(planeNode)
      anchors.append(planeAnchor)
      
    } else {
      print("not plane anchor \(anchor)")
    }
    return node
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    if let planeAnchor = anchor as? ARPlaneAnchor {
      if anchors.contains(planeAnchor) {
        if node.childNodes.count > 0 {
          let planeNode = node.childNodes.first!
          planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight / 2), planeAnchor.center.z)
          planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeNode.geometry!, options: nil))
          if let plane = planeNode.geometry as? SCNBox {
            plane.width = CGFloat(planeAnchor.extent.x)
            plane.length = CGFloat(planeAnchor.extent.z)
            plane.height = planeHeight
          }
        }
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    print("here")
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    print("Interupted")
  }
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    print("camera changing")
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    print("Error: ", error)
  }
}

