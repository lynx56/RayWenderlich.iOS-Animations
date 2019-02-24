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
import QuartzCore

@IBDesignable
class AnimatedMaskLabel: UIView {
    let gradientProvider: GradientProvider
    let gradientLayer: CAGradientLayer
    
    init(gradientProvider: GradientProvider) {
        self.gradientProvider = gradientProvider
        gradientLayer = gradientProvider.makeLayer()
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.gradientProvider = PsychedelicGradient()
        gradientLayer = gradientProvider.makeLayer()
        super.init(coder: aDecoder)
    }
    
    @IBInspectable var text: String! {
        didSet {
            setNeedsDisplay()
            let image = UIGraphicsImageRenderer(size: bounds.size).image { _ in
                text.draw(in: bounds, withAttributes: textAttributes)
            }
            
            let mask = CALayer()
            mask.backgroundColor = UIColor.clear.cgColor
            mask.frame = bounds.offsetBy(dx: bounds.width, dy: 0)
            mask.contents = image.cgImage
            gradientLayer.mask = mask
        }
    }
    
    let textAttributes: [NSAttributedStringKey: AnyObject] = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Thin", size: 28)!,
                NSAttributedStringKey.paragraphStyle: style]
    }()
    
    override func layoutSubviews() {
        layer.borderColor = UIColor.green.cgColor
        gradientLayer.frame = CGRect(x: -bounds.size.width, y: bounds.origin.y,
                                     width: 3*bounds.width, height: bounds.size.height)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        layer.addSublayer(gradientLayer)
        gradientLayer.add(gradientProvider.makeAnimation(),
                          forKey: nil)
    }
}

extension CABasicAnimation {
    static func makeMovingGradient(from: [NSNumber], to: [NSNumber], duration: CFTimeInterval) -> CABasicAnimation {
        let gradient = CABasicAnimation(keyPath: "locations")
        gradient.fromValue = from
        gradient.toValue = to
        gradient.duration = 3
        gradient.repeatCount = Float.infinity
        return gradient
    }
}




