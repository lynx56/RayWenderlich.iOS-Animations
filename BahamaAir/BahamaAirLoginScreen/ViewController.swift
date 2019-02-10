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
    
    var statusPosition = CGPoint.zero
    
    // MARK: view controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addloginButton()
        self.configureStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let viewWidth = view.bounds.width
        heading.center.x -= viewWidth
        username.center.x -= viewWidth
        password.center.x -= viewWidth
        
        cloud1.alpha = 0
        cloud2.alpha = 0
        cloud3.alpha = 0
        cloud4.alpha = 0
        
        loginButton.center.y += 30
        loginButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let viewWidth = self.view.bounds.width
        
        UIView.animate(withDuration: 0.5) {
            self.heading.center.x += viewWidth
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [], animations: {
            self.username.center.x += viewWidth
        }, completion: nil)
      
        UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [], animations: {
             self.password.center.x += viewWidth
        }, completion: nil)
        
        animateCloud(cloud1, withDelay: 0.5)
        animateCloud(cloud2, withDelay: 0.7)
        animateCloud(cloud3, withDelay: 0.9)
        animateCloud(cloud4, withDelay: 1.1)
        
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginButton.center.y -= 30
            self.loginButton.alpha = 1.0
        }, completion: nil)
        
        moveCloud(cloud1)
        moveCloud(cloud2)
        moveCloud(cloud3)
        moveCloud(cloud4)
    }
    
    func animateCloud(_ cloud: UIImageView, withDelay delay: TimeInterval){
        UIView.animate(withDuration: 1, delay: delay, options: [.curveEaseOut], animations: {
            cloud.alpha = 1.0
            }, completion: nil)
    }
    
    var cloudSpeed: CGFloat = 60
    func moveCloud(_ cloud: UIImageView) {
        let speed = cloudSpeed / view.frame.size.width
        let duration = (view.frame.size.width - cloud.frame.origin.x) * speed
        
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: .curveLinear, animations: {
            cloud.frame.origin.x = self.view.frame.size.width
        }, completion: { _ in
            cloud.frame.origin.x = -cloud.frame.size.width
        })
    }
    
    //MARK: setup view Subviews
    
    private func addloginButton(){
        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        
        spinner.frame = CGRect(x: -20.0, y: 6.0, width: 20.0, height: 20.0)
        spinner.startAnimating()
        spinner.alpha = 0.0
        loginButton.addSubview(spinner)
    }
    
    private func configureStatus(){
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
        }, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextField = (textField === username) ? password : username
        nextField?.becomeFirstResponder()
        return true
    }
    
}
