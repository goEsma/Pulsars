//
//  CameraNavigator.swift
//  CameraNavigator
//
//  Created by Onur Ornek on 1/18/20.
//  Copyright © 2020 Onur Ornek. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

///Any class who wants to be notified by the CameraNavigator must conform to this protocol.
public protocol CameraNavigatorDelegate {
    func didUpdateOrientation(to orientation: SCNQuaternion)
    func didUpdateVerticalFieldOfView(to vfov: CGFloat)
}

/** CameraNavigator is a class that handles gestures and device motion
 to keep track of an orientation and a zoom factor. The orientation and
 the zoom factor are designed to belong to a camera.
    - orientation is in the form of a quaternion
    - zoom factor is expressed in terms of vertical field of view,
 which represents the angle of sight (in degrees) between the bottom
 and the top of a view. */
class CameraNavigator {
    let gestureController: GestureController
    let viewSize: CGSize
    var verticalFieldOfView: CGFloat {
        didSet {
            if let navigatorDelegate = delegate {
                navigatorDelegate.didUpdateVerticalFieldOfView(to: verticalFieldOfView)
            }
        }
    }
    var verticalFieldOfViewInRadian: CGFloat {
        get {
            return verticalFieldOfView * CGFloat.pi / 180.0
        }
        set(newVerticalFieldOfViewInRadian) {
            verticalFieldOfView = newVerticalFieldOfViewInRadian * 180.0 / CGFloat.pi
        }
    }
    var orientation: GLKQuaternion {
        didSet {
            if let navigatorDelegate = delegate {
                navigatorDelegate.didUpdateOrientation(to: SCNQuaternion(orientation))
            }
        }
    }
    var delegate: CameraNavigatorDelegate?
    var anglePerDistance: CGFloat {
        get {
            return verticalFieldOfViewInRadian / viewSize.height
        }
    }
    
    fileprivate static let maxFieldOfViewInRadian = CGFloat(2)
    fileprivate static let minFieldOfViewInRadian = CGFloat(0.1)
    
    init(with view: UIView, initialOrientation: SCNQuaternion, verticalFieldOfView: CGFloat) {
        gestureController = GestureController(with: view)
        viewSize = view.bounds.size
        orientation = GLKQuaternion(initialOrientation)
        self.verticalFieldOfView = verticalFieldOfView
        gestureController.delegate = self
    }
    
    /** To be called to use pan and rotation gestures to navigate the orientation.
        Zoom is always controlled by the pinch gesture. */
    func setModeToGesture() {
        gestureController.enabled = true
    }
    
    /** To be called to use device motion to navigate the orientation.
        Zoom is always controlled by the pinch gesture. */
    func setModeToDeviceMotion(with initialOrientation: SCNQuaternion) {
        gestureController.enabled = false
        orientation = GLKQuaternion(initialOrientation)
    }
}

extension CameraNavigator: GestureDelegate {
    func didPan(by vector: CGVector) {
        let horizontalAngle = Float(vector.dx * anglePerDistance) * (-1.0)
        let verticalAngle = Float(vector.dy * anglePerDistance) * (-1.0)
        let horizontalRotation = GLKQuaternionMakeWithAngleAndAxis(horizontalAngle, 0, 1, 0)
        let verticalRotation = GLKQuaternionMakeWithAngleAndAxis(verticalAngle, 1, 0, 0)
        let totalRotation = GLKQuaternionMultiply(horizontalRotation, verticalRotation)
        orientation = GLKQuaternionMultiply(totalRotation, orientation)
    }
    
    func didRotate(by angle: CGFloat) {
        let rotationAngle = Float(angle) * (-1.0)
        let rotation = GLKQuaternionMakeWithAngleAndAxis(rotationAngle, 0, 0, 1)
        orientation = GLKQuaternionMultiply(rotation, orientation)
    }
    
    func didScale(by ratio: CGFloat) {
        let newFieldOfView = verticalFieldOfViewInRadian / ratio
        if (newFieldOfView > CameraNavigator.maxFieldOfViewInRadian) {
            verticalFieldOfViewInRadian = CameraNavigator.maxFieldOfViewInRadian
        } else if (newFieldOfView < CameraNavigator.minFieldOfViewInRadian) {
            verticalFieldOfViewInRadian = CameraNavigator.minFieldOfViewInRadian
        } else {
            verticalFieldOfViewInRadian = newFieldOfView
        }
    }
}


