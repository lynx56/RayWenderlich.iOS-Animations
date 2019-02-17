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

// A delay function
func delay(_ seconds: Double, completion: @escaping ()->Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

class ViewController: UIViewController {
    
    // MARK: IB outlets
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var heading: UILabel!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBOutlet var cloud1: UIImageView!
    @IBOutlet var cloud2: UIImageView!
    @IBOutlet var cloud3: UIImageView!
    @IBOutlet var cloud4: UIImageView!
    
    // MARK: further UI
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let status = UIImageView(image: UIImage(named: "banner"))
    let label = UILabel()
    let messages = ["Connecting ...", "Authorizing ...", "Sending credentials ...", "Failed"]
    let info = UILabel()
    
    var statusPosition = CGPoint.zero
    
    // MARK: view controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addloginButton()
        self.setupStatus()
        self.setupInfoLabel()
        
        username.delegate = self
        password.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateForm()
        let opacityAnimation = CABasicAnimation.makeOpacity()
        opacityAnimation.beginTime = CACurrentMediaTime() + 0.5
        cloud1.layer.add(opacityAnimation, forKey: nil)
        opacityAnimation.beginTime = CACurrentMediaTime() + 0.7
        cloud2.layer.add(opacityAnimation, forKey: nil)
        opacityAnimation.beginTime = CACurrentMediaTime() + 0.9
        cloud3.layer.add(opacityAnimation, forKey: nil)
        opacityAnimation.beginTime = CACurrentMediaTime() + 1.1
        cloud4.layer.add(opacityAnimation, forKey: nil)
    }
    
    private func animateForm() {
        let groupAnimation = CAAnimationGroup()
        let fadeIn = CABasicAnimation.makeOpacity(from: 0.25, to: 1)
        let flyRight = CABasicAnimation.makeHorizontalMove(from: -view.bounds.width/2, to: view.bounds.width/2)
        flyRight.toValue = view.bounds.width/2
        groupAnimation.animations = [flyRight, fadeIn]
        groupAnimation.delegate = self
        groupAnimation.duration = 1.5
        groupAnimation.fillMode = kCAFillModeBackwards
        add(animation: groupAnimation, to: heading.layer, with: "heading")
        groupAnimation.beginTime = CACurrentMediaTime() + 0.3
        add(animation: groupAnimation, to: username.layer, with: "username")
        groupAnimation.beginTime = CACurrentMediaTime() + 0.4
        add(animation: groupAnimation, to: password.layer, with: "password")
    }
    
    private func add(animation: CAAnimation, to layer: CALayer, with name: String) {
        animation.setValue(name, forKey: "name")
        animation.setValue(layer, forKey: "layer")
        layer.add(animation, forKey: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        moveCloud(cloud1.layer)
        moveCloud(cloud2.layer)
        moveCloud(cloud3.layer)
        moveCloud(cloud4.layer)
        moveInfoWithFadeIn()
        appearLoginWithRotationAndScaling()
    }
    
    func moveInfoWithFadeIn() {
        let flyLeft = CABasicAnimation.makeHorizontalMove(from: info.layer.position.x + view.frame.size.width,
                                                                      to: info.layer.position.x,
                                                                      duration: 5.0)
        flyLeft.repeatCount = 2.5
        flyLeft.autoreverses = true
        info.layer.add(flyLeft, forKey: "infoappear")
        let fade = CABasicAnimation.makeOpacity(from: 0.2, to: 1, duration: 4.5)
        info.layer.add(fade, forKey: "fadein")
    }
    
    func appearLoginWithRotationAndScaling() {
        let groupAnimation = CAAnimationGroup()
        groupAnimation.beginTime = CACurrentMediaTime() + 0.5
        groupAnimation.duration = 0.5
        groupAnimation.fillMode = kCAFillModeBackwards
        groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        let scaleDown = CABasicAnimation.makeScale(from: 3.5, to: 1)
        let rotate = CABasicAnimation.makeRotation(from: .pi/4.0, to: 0)
        let fade = CABasicAnimation.makeOpacity(from: 0, to: 1)
        
        groupAnimation.animations = [scaleDown, rotate, fade]
        loginButton.layer.add(groupAnimation, forKey: nil)
    }
    
    var cloudSpeed: CGFloat = 60
    func moveCloud(_ layer: CALayer) {
        let speed = cloudSpeed / view.frame.size.width
        let duration = (view.frame.size.width - layer.frame.origin.x) * speed
        
        let animation = CABasicAnimation.makeHorizontalMove(to: self.view.bounds.width + layer.bounds.width/2,
                                                                 duration: CFTimeInterval(duration))
        animation.delegate = self
        animation.setValue("cloud", forKey: "name")
        animation.setValue(layer, forKey: "layer")
        layer.add(animation, forKey: nil)
    }
    
    private func setupInfoLabel() {
        info.frame = CGRect(x: 0, y: loginButton.center.y + 60, width: view.frame.size.width, height: 30)
        info.backgroundColor = UIColor.clear
        info.font = UIFont(name: "HelveticaNeue", size: 12)
        info.textAlignment = .center
        info.textColor = UIColor.white
        info.text = "Tap on a field and enter username and password"
        view.insertSubview(info, belowSubview: loginButton)
    }
    
    //MARK: setup view Subviews
    
    private func addloginButton() {
        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        
        spinner.frame = CGRect(x: -20.0, y: 6.0, width: 20.0, height: 20.0)
        spinner.startAnimating()
        spinner.alpha = 0.0
        loginButton.addSubview(spinner)
    }
    
    private func setupStatus(){
        status.isHidden = true
        status.center = loginButton.center
        statusPosition = status.center
        view.addSubview(status)
        
        label.frame = CGRect(x: 0.0, y: 0.0, width: status.frame.size.width, height: status.frame.size.height)
        label.font = UIFont(name: "HelveticaNeue", size: 18.0)
        label.textColor = UIColor(red: 0.89, green: 0.38, blue: 0.0, alpha: 1.0)
        label.textAlignment = .center
        status.addSubview(label)
    }
    
    // MARK: further methods
    
    @IBAction func login() {
        view.endEditing(true)
        
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginButton.bounds.size.width += 80
        }) { _ in
            self.showMessage(index: 0)
        }
        
        UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginButton.center.y += 60
            self.loginButton.backgroundColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
            self.spinner.center = CGPoint(x: 40, y: self.loginButton.frame.size.height/2)
            self.spinner.alpha = 1.0
        }, completion: nil)
        
        let tintColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
    //    loginButton.layer.changeBackgroundColor(to: tintColor)
        loginButton.layer.changeBackgroundColorBySpring(to: tintColor)
     //   loginButton.layer.roundCorners(to: 25.0)
        loginButton.layer.roundCornersBySpring(to: 25.0)
    }
    
    func showMessage(index: Int) {
        label.text = messages[index]
        
        UIView.transition(with: status, duration: 0.33, options: [.curveEaseOut, .transitionCurlDown], animations: {
            self.status.isHidden = false
        }){ _ in
            if index < self.messages.count - 1 {
                self.removeMessage(at: index)
            } else {
                self.resetForm()
            }
        }
    }
    
    func removeMessage(at index: Int) {
        UIView.animate(withDuration: 0.33, delay: 0, options: [], animations: {
            self.status.center.x += self.view.frame.width
        }){ _ in
            self.status.isHidden = true
            self.status.center = self.statusPosition
            
            self.showMessage(index: index + 1)
        }
    }
    
    func resetForm(){
        UIView.transition(with: self.status, duration: 0.2, options: [.curveEaseOut, .transitionCurlUp], animations: {
            self.status.isHidden = true
            self.status.center = self.statusPosition
        }, completion: nil)
        
        UIView.animate(withDuration: 0.33, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            self.spinner.alpha = 0
            self.spinner.frame.origin = CGPoint(x: -20, y: 16)
            self.loginButton.backgroundColor = UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1)
            self.loginButton.bounds.size.width -= 80
            self.loginButton.center.y -= 60
        }, completion: { _ in
            let loginButtonLayer = self.loginButton.layer
       //     loginButtonLayer.changeBackgroundColor(to: UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0))
            loginButtonLayer.changeBackgroundColorBySpring(to: UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0))
           // loginButtonLayer.roundCorners(to: 10.0)
            loginButtonLayer.roundCornersBySpring(to: 10.0)
        })
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextField = (textField === username) ? password : username
        nextField?.becomeFirstResponder()
        return true
    }
    
}

extension ViewController: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        print("\(anim.value(forKey: "name")) did start")
        
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("\(anim.value(forKey: "name")) did stop")
        if anim.value(forKey: "name") as? String == "username" {
            let layer = anim.value(forKey: "layer") as? CALayer
            anim.setValue(nil, forKey: "layer")
            let pulse = CASpringAnimation.makePulse(initialScale: 1.25, endScale: 1, damping: 7.5)
            layer?.add(pulse, forKey: nil)
        }
        
        if anim.value(forKey: "name") as? String == "cloud",  let layer = anim.value(forKey: "layer") as? CALayer {
            layer.position.x = -layer.bounds.width/2
            delay(0.5) {
                self.moveCloud(layer)
            }
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        info.layer.removeAnimation(forKey: "infoappear")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count < 5 {
            let jump = CASpringAnimation.makeJump(from: textField.layer.position.y + 1,
                                                  to: textField.layer.position.y,
                                                  initialVelocity: 100,
                                                  mass: 10,
                                                  stiffness: 1500,
                                                  damping: 50)
            textField.layer.add(jump, forKey: nil)
            textField.layer.borderWidth = 3
            textField.layer.borderColor = UIColor.clear.cgColor
            let flash = CASpringAnimation.makeFlash(startColor: UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0),
                                                    endColor: UIColor.white,
                                                    damping: 7,
                                                    stiffness: 200)
            textField.layer.add(flash, forKey: nil)
        }
    }
}

extension CABasicAnimation {
    static func makeHorizontalMove(from: CGFloat? = nil, to: CGFloat, duration: CFTimeInterval = 0.5) -> CABasicAnimation {
        let basicAnimation = CABasicAnimation(keyPath: "position.x")
        if let from = from {
            basicAnimation.fromValue = from
        }
        basicAnimation.toValue = to
        basicAnimation.duration = duration
        basicAnimation.fillMode = kCAFillModeBoth
        basicAnimation.isRemovedOnCompletion = true
        return basicAnimation
    }
    
    static func makeOpacity(from: CGFloat = 0, to: CGFloat = 1, duration: CFTimeInterval = 0.5) -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = from
        opacityAnimation.toValue = to
        opacityAnimation.duration = duration
        opacityAnimation.fillMode = kCAFillModeBoth
        return opacityAnimation
    }
    
    static func makeScale(from: CGFloat, to: CGFloat) -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = from
        scaleAnimation.toValue = to
        return scaleAnimation
    }
    
    static func makeRotation(from: CGFloat, to: CGFloat) -> CABasicAnimation {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = from
        rotateAnimation.toValue = to
        return rotateAnimation
    }
}

extension CASpringAnimation {
    static func makePulse(initialScale: CGFloat, endScale: CGFloat, damping: CGFloat) -> CASpringAnimation {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.fromValue = initialScale
        pulse.toValue = endScale
        pulse.damping = damping
        pulse.duration = pulse.settlingDuration
        return pulse
    }
    
    static func makeJump(from: CGFloat, to: CGFloat, initialVelocity: CGFloat = 0, mass: CGFloat = 1, stiffness: CGFloat = 100, damping: CGFloat = 10) -> CASpringAnimation {
        let jump = CASpringAnimation(keyPath: "position.y")
        jump.fromValue = from
        jump.toValue = to
        jump.duration = jump.settlingDuration
        jump.initialVelocity = initialVelocity
        jump.mass = mass
        jump.stiffness = stiffness
        jump.damping = damping
        return jump
    }
    
    static func makeFlash(startColor: UIColor, endColor: UIColor, damping: CGFloat, stiffness: CGFloat) -> CASpringAnimation {
        let flash = CASpringAnimation(keyPath: "borderColor")
        flash.damping = damping
        flash.stiffness = stiffness
        flash.fromValue = startColor.cgColor
        flash.toValue = endColor.cgColor
        flash.duration = flash.settlingDuration
        return flash
    }
}

extension CALayer {
    func changeBackgroundColor(to color: UIColor) {
        let basicAnimation = CABasicAnimation(keyPath: "backgroundColor")
        basicAnimation.fromValue = self.backgroundColor
        basicAnimation.toValue = color.cgColor
        basicAnimation.duration = 1.0
        self.add(basicAnimation, forKey: nil)
        self.backgroundColor = color.cgColor
    }
    
    func changeBackgroundColorBySpring(to color: UIColor, damping: CGFloat = 10, stiffness: CGFloat = 100) {
        let changeBackground = CASpringAnimation(keyPath: "backgroundColor")
        changeBackground.damping = damping
        changeBackground.stiffness = stiffness
        changeBackground.fromValue = self.backgroundColor
        changeBackground.toValue = color.cgColor
        changeBackground.duration = changeBackground.settlingDuration
        self.add(changeBackground, forKey: nil)
        self.backgroundColor = color.cgColor
    }
    
    func roundCorners(to radius: CGFloat) {
        let basicAnimation = CABasicAnimation(keyPath: "cornerRadius")
        basicAnimation.fromValue = self.cornerRadius
        basicAnimation.toValue = radius
        basicAnimation.duration = 0.33
        self.add(basicAnimation, forKey: nil)
        self.cornerRadius = radius
    }
    
    func roundCornersBySpring(to radius: CGFloat, damping: CGFloat = 100, stiffness: CGFloat = 100) {
        let roundCorners = CASpringAnimation(keyPath: "cornerRadius")
        roundCorners.damping = damping
        roundCorners.stiffness = stiffness
        roundCorners.fromValue = self.cornerRadius
        roundCorners.toValue = radius
        roundCorners.duration = roundCorners.settlingDuration
        self.add(roundCorners, forKey: nil)
        self.cornerRadius = radius
    }
}
