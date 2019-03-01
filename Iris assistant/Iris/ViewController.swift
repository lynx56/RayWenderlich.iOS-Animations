/*
 * Copyright (c) 2014-present Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var meterLabel: UILabel!
    @IBOutlet weak var speakButton: UIButton!
    
    let monitor = MicMonitor()
    let assistant = Assistant()
    
    let replicator = CAReplicatorLayer()
    let dot = CALayer()
    let dotLength: CGFloat = 6
    let dotOffset: CGFloat = 8
    var lastTransformScale: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        replicator.frame = view.bounds
        view.layer.addSublayer(replicator)
        dot.frame = CGRect(x: replicator.frame.width - dotLength,
                           y: replicator.position.y,
                           width: dotLength,
                           height: dotLength)
        dot.backgroundColor = UIColor.lightGray.cgColor
        dot.borderColor = UIColor(white: 1, alpha: 1).cgColor
        dot.borderWidth = 0.5
        dot.cornerRadius = 1.5
        replicator.addSublayer(dot)
        replicator.instanceCount = Int(view.frame.width / dotOffset)
        replicator.instanceTransform = CATransform3DMakeTranslation(-dotOffset, 0.0, 0.0)
       /* dot.add(CABasicAnimation.makeVerticalMove(from: dot.position.y,
                                                  to: dot.position.y - 50,
                                                  duration: 1,
                                                  repeatCount: 10),
                forKey: nil)*/
        replicator.instanceDelay = 0.02
    }
    
    @IBAction func actionStartMonitoring(_ sender: AnyObject) {
        dot.backgroundColor = UIColor.green.cgColor
        monitor.startMonitoringWithHandler { [unowned self] level in
            self.meterLabel.text = String(format: "%.2f db", level)
            let scaleFactor = max(0.2, CGFloat(level) + 50) / 2
            let scale = CABasicAnimation.makeVerticalScale(from: self.lastTransformScale, to: scaleFactor, duration: 0.1)
            self.dot.add(scale, forKey: nil)
            self.lastTransformScale = scaleFactor
        }
    }
    
    @IBAction func actionEndMonitoring(_ sender: AnyObject) {
        monitor.stopMonitoring()
        let identityScaleTransform = CABasicAnimation.makeVerticalScale(from: nil, to: 1, duration: 0.5)
        dot.add(identityScaleTransform, forKey: nil)
        let tint = CABasicAnimation.makeTint(from: .green, to: .magenta, durarion: 0.5, delay: 0)
        dot.add(tint, forKey: nil)
        
        delay(seconds: 1.0) {
            self.startSpeaking()
        }
    }
    
    func startSpeaking() {
        meterLabel.text = assistant.randomAnswer()
        assistant.speak(meterLabel.text!, completion: endSpeaking)
        speakButton.isHidden = true
        let scale = CABasicAnimation.make3DScale(x: 1.4, y: 15, z: 1.0, duration: 0.33)
        dot.add(scale, forKey: "dotScale")
        let fade = CABasicAnimation.makeFade(from: 1, to: 0.2)
        dot.add(fade, forKey: "dotOpacity")
        let tint = CABasicAnimation.makeTint(from: .magenta, to: .cyan, durarion: 0.66, delay: 0.28)
        dot.add(tint, forKey: "dotColor")
/*
        //PSYHO animation
        let instanceRotation = CABasicAnimation.makeInstanceRotation(from: 0, to: 0.01, duration: 0.33)
        replicator.add(instanceRotation, forKey: "initialRotation")
        let rotation = CABasicAnimation.makeInstanceRotation(from: 0.01, to: -0.01, duration: 0.99, delay: 0.33, autoreverses: true, isRemovedOnCompletion: true)
        replicator.add(rotation, forKey: "replicatorRotation")
*/
    }
    
    func endSpeaking() {
        replicator.removeAllAnimations()
        dot.removeAnimation(forKey: "dotColor")
        dot.removeAnimation(forKey: "dotOpacity")
        
        dot.add(CABasicAnimation.makeResetScale(), forKey: nil)
        dot.backgroundColor = UIColor.lightGray.cgColor
        speakButton.isHidden = false
    }
}

extension CABasicAnimation {
    static func makeVerticalMove(from: CGFloat, to: CGFloat, duration: CFTimeInterval, repeatCount: Float = 1) -> CABasicAnimation {
        let move = CABasicAnimation(keyPath: "position.y")
        move.fromValue = from
        move.toValue = to
        move.duration = duration
        move.repeatCount = repeatCount
        return move
    }
    
    static func makeVerticalScale(from: CGFloat?, to: CGFloat, duration: CFTimeInterval) -> CABasicAnimation {
        let scale = CABasicAnimation(keyPath: "transform.scale.y")
        if let from = from {
            scale.fromValue = from
        }
        scale.toValue = to
        scale.duration = duration
        scale.isRemovedOnCompletion = false
        scale.fillMode = kCAFillModeForwards
        return scale
    }
    
    static func make3DScale(x: CGFloat, y: CGFloat, z: CGFloat, duration: CFTimeInterval) -> CABasicAnimation{
        let scale = CABasicAnimation(keyPath: "transform")
        scale.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scale.toValue = NSValue(caTransform3D: CATransform3DMakeScale(x, y, z))
        scale.duration = duration
        scale.repeatCount = .infinity
        scale.autoreverses = true
        scale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        return scale
    }
    
    static func makeResetScale(duration: CFTimeInterval = 0.33) -> CABasicAnimation {
        let scale = CABasicAnimation(keyPath: "transform")
        scale.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        scale.duration = duration
        scale.isRemovedOnCompletion = false
        scale.fillMode = kCAFillModeForwards
        return scale
    }
    
    static func makeFade(from: CGFloat = 1, to: CGFloat = 0, delay: CFTimeInterval = 0.33, duration: CFTimeInterval = 0.33) -> CABasicAnimation {
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = from
        fade.toValue = to
        fade.duration = duration
        fade.beginTime = CACurrentMediaTime() + delay
        fade.repeatCount = .infinity
        fade.autoreverses = true
        fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        return fade
    }
    
    static func makeTint(from: UIColor, to: UIColor, durarion: CFTimeInterval, delay: CFTimeInterval) -> CABasicAnimation {
        let tint = CABasicAnimation(keyPath: "backgroundColor")
        tint.fromValue = from.cgColor
        tint.toValue = to.cgColor
        tint.duration = durarion
        tint.beginTime = CACurrentMediaTime() + delay
        tint.fillMode = kCAFillModeBackwards
        tint.repeatCount = .infinity
        tint.autoreverses = true
        tint.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        return tint
    }
    
    static func makeInstanceRotation(from: CGFloat, to: CGFloat, duration: CFTimeInterval, delay: CFTimeInterval = 0, autoreverses: Bool = false, isRemovedOnCompletion: Bool = false) -> CABasicAnimation {
        let rotation = CABasicAnimation(keyPath: "instanceTransform.rotation")
        rotation.fromValue = from
        rotation.toValue = to
        rotation.duration = duration
        rotation.autoreverses = autoreverses
        rotation.beginTime = CACurrentMediaTime() + delay
        rotation.isRemovedOnCompletion = isRemovedOnCompletion
        rotation.fillMode = kCAFillModeForwards
        rotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        return rotation
    }
}
