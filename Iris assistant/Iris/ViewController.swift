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
        dot.add(CABasicAnimation.makeVerticalMove(from: dot.position.y,
                                                  to: dot.position.y - 50,
                                                  duration: 1,
                                                  repeatCount: 10),
                forKey: nil)
        replicator.instanceDelay = 0.02
    }
    
    @IBAction func actionStartMonitoring(_ sender: AnyObject) {
        
    }
    
    @IBAction func actionEndMonitoring(_ sender: AnyObject) {
        
        //speak after 1 second
        delay(seconds: 1.0) {
            self.startSpeaking()
        }
    }
    
    func startSpeaking() {
        print("speak back")
        let scale = CABasicAnimation.make3DScale(x: 1.4, y: 15, z: 1.0, duration: 0.33)
        dot.add(scale, forKey: nil)
    }
    
    func endSpeaking() {
        
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
}
