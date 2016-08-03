//
//  GameViewController.swift
//  MetalSCNTechnique
//
//  Created by M.Ike on 2016/07/12.
//  Copyright (c) 2016年 M.Ike. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    @IBOutlet weak private var scnView: SCNView!
    
    private struct SceneData {
        var scene: SCNScene
        var technique: SCNTechnique
    }
    
    private var sceneList = [SceneData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // drop
        if let scene = SCNScene(named: "art.scnassets/ship.scn"), technique = loadTechnique("drop") {
            if let ship = scene.rootNode.childNodeWithName("ship", recursively: true) {
                ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
            }
            
            sceneList.append(SceneData(scene: scene, technique: technique))
        }
 
        // depth
        if let scene = SCNScene(named: "art.scnassets/box.scn"), technique = loadTechnique("depth") {
            sceneList.append(SceneData(scene: scene, technique: technique))
        }
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        

        // set the scene to the view
        scnView.scene = sceneList[1].scene
        scnView.technique = sceneList[1].technique
    }
    
    private func loadTechnique(name: String) -> SCNTechnique? {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist"),
            let dic = NSDictionary(contentsOfFile: path) as? [String : AnyObject] else { return nil }
        return SCNTechnique(dictionary: dic)
    }
    
    @IBAction private func changeTechnique(sender: UISegmentedControl) {
        guard sceneList.indices.contains(sender.selectedSegmentIndex) else { return }
        scnView.scene = sceneList[sender.selectedSegmentIndex].scene
        scnView.technique = sceneList[sender.selectedSegmentIndex].technique
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
