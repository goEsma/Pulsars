//
//  SphereNode.swift
//  SoundOfPulsars
//
//  Created by EsmaGO on 12/22/19.
//  Copyright © 2019 EsmaGO. All rights reserved.
//

import SceneKit
import PulsarDatasource

final class SphereNode: SCNNode {
    
    static let shared:SphereNode = SphereNode()
    let pulsarsNode = SCNNode()
    let textsNode   = SCNNode()
    let paralelsAndMeridiansNode = CelestialCirclesNode.shared
    
    private override init() {
        super.init()

        geometry = SCNSphere(radius: 10)
        geometry?.firstMaterial?.isDoubleSided = true
        geometry?.firstMaterial?.diffuse.contents = UIImage.starMap
        position = SCNVector3Make(0, 0, 0)
        
        createPulsarsAndTexts()
        addChildNode(pulsarsNode)
        addChildNode(textsNode)
        addChildNode(paralelsAndMeridiansNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createPulsarsAndTexts() {
        for pulsar in Datasource.audiblePulsars {
            let pNode = PulsarNode(with: pulsar)
            let tNode = TextNode(with: pulsar)
            pulsarsNode.addChildNode(pNode)
            textsNode.addChildNode(tNode)
        }
    }
    
    func addPulsars() {
        if childNodes.contains(pulsarsNode) { return }
        self.addChildNode(pulsarsNode)
    }
    
    func removePulsars() {
        pulsarsNode.removeFromParentNode()
    }
    
    func addTexts() {
        if childNodes.contains(textsNode) { return }
        self.addChildNode(textsNode)
    }
    func removeTexts() {
        textsNode.removeFromParentNode()
    }
    
}
