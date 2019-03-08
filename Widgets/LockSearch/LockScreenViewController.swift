/*
 * Copyright (c) 2016-present Razeware LLC
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

// image by NASA: https://www.flickr.com/photos/nasacommons/29193068676/

import UIKit

class LockScreenViewController: UIViewController {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var dateTopConstraint: NSLayoutConstraint!
  
  let blurView = UIVisualEffectView(effect: nil)
  
  var settingsController: SettingsViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.bringSubview(toFront: searchBar)
    blurView.effect = UIBlurEffect(style: .dark)
    blurView.alpha = 0
    blurView.isUserInteractionEnabled = false
    view.insertSubview(blurView, belowSubview: searchBar)
    
    tableView.estimatedRowHeight = 130.0
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    AnimatorFactory.scaleUp(view: tableView).startAnimation()
  }
  
  override func viewWillLayoutSubviews() {
    blurView.frame = view.bounds
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  @IBAction func presentSettings(_ sender: Any? = nil) {
    //present the view controller
    settingsController = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
    present(settingsController, animated: true, completion: nil)
  }
  
  func toggleBlur(_ blurred: Bool) {
    UIViewPropertyAnimator(duration: 0.55, curve: .easeOut, animations: blurAnimations(blurred))
      .startAnimation()
  }
  
  func blurAnimations(_ blurred: Bool) -> () -> Void {
    return {
      self.blurView.effect = blurred ? UIBlurEffect(style: .dark) : nil
      self.tableView.transform = blurred ? CGAffineTransform(scaleX: 0.75, y: 0.75) : .identity
      self.blurView.alpha = blurred ? 0.33 : 1.0
    }
  }
}

extension LockScreenViewController: WidgetsOwnerProtocol { }

extension LockScreenViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Footer") as! FooterCell
      cell.didPressEdit = {[unowned self] in
        self.presentSettings()
      }
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WidgetCell
      cell.tableView = tableView
      cell.owner = self
      return cell
    }
  }
}

extension LockScreenViewController: UISearchBarDelegate {
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    toggleBlur(true)
  }
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    toggleBlur(false)
  }
  func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      searchBar.resignFirstResponder()
    }
  }
}


class AnimatorFactory {
  static func scaleUp(view: UIView) -> UIViewPropertyAnimator {
    let scale = UIViewPropertyAnimator(duration: 0.33, curve: .easeIn)
    scale.addAnimations {
      view.alpha = 1
    }
    scale.addAnimations({
      view.transform = .identity
    }, delayFactor: 0.33)
    
    scale.addCompletion { _ in
      print("ready")
    }
    return scale
  }
  
  @discardableResult
  static func jiggle(view: UIView) -> UIViewPropertyAnimator {
    return UIViewPropertyAnimator.runningPropertyAnimator(
      withDuration: 0.33, delay: 0,
      options: .curveLinear,
      animations: {
        UIView.animateKeyframes(withDuration: 1, delay: 0, animations: {
          UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
            view.transform = CGAffineTransform(rotationAngle: -.pi/8)
          })
          UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.75, animations: {
            view.transform = CGAffineTransform(rotationAngle: .pi/8)
          })
          UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 1, animations: {
            view.transform = .identity
          })
        }, completion: nil)
    })
  }
  
  @discardableResult
  static func fade(blurView: UIView, visible: Bool) -> UIViewPropertyAnimator {
    return UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5,
                                                          delay: 0.1,
                                                          options: [.curveEaseOut],
                                                          animations: {
                                                            blurView.alpha = visible ? 1 : 0
    },
                                                          completion: nil)
  }
}
