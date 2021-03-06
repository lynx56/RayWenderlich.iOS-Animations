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
  private var _startFrame: CGRect?
  private var _previewView: UIView?
  private var _previewAnimator: UIViewPropertyAnimator?
  private let _previewEffectView = IconEffectView(blur: .extraLight)
  private let _presentTransition = PresentTransition()
  private var _isDragging = false
  private var _isPresentingSettings = false
  private var _touchesStartPointY: CGFloat?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.bringSubview(toFront: searchBar)
    blurView.isUserInteractionEnabled = false
    view.insertSubview(blurView, belowSubview: searchBar)
    
    tableView.estimatedRowHeight = 130.0
    tableView.rowHeight = UITableViewAutomaticDimension
    
    _previewEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.transform = CGAffineTransform(scaleX: 0.67, y: 0.67)
    tableView.alpha = 0
    
    dateTopConstraint.constant -= 100
    view.layoutIfNeeded()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    AnimatorFactory.scaleUp(view: tableView).startAnimation()
    AnimatorFactory.animateConstraint(view: view, constraint: dateTopConstraint, by: 100).startAnimation()
  }
  
  override func viewWillLayoutSubviews() {
    blurView.frame = view.bounds
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  @IBAction func presentSettings(_ sender: Any? = nil) {
    _presentTransition.auxAnimations = blurAnimations(true)
    _presentTransition.auxAnimationsCancel = blurAnimations(false)
    
    settingsController = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
    settingsController.transitioningDelegate = self
    settingsController.didDismiss = { [unowned self] in
      self.toggleBlur(false)
    }
    present(settingsController, animated: true, completion: nil)
  }
  
  func toggleBlur(_ blurred: Bool) {
    UIViewPropertyAnimator(duration: 0.55,
                           controlPoint1: CGPoint(x: 0.57, y: -0.4),
                           controlPoint2: CGPoint(x: 0.96, y: 0.87),
                           animations: blurAnimations(blurred))
      .startAnimation()
    
    /*
     // Spring
     let spring = UISpringTimingParameters(mass: 10, stiffness: 5, damping: 30, initialVelocity: CGVector(dx: 1, dy: 0.2))
     let animator = UIViewPropertyAnimator(duration: 0.55, timingParameters: spring)
     animator.addAnimations(blurAnimations(blurred))
     animator.startAnimation()
     */
  }
  
  func blurAnimations(_ blurred: Bool) -> () -> Void {
    return {
      self.blurView.effect = blurred ? UIBlurEffect(style: .dark) : nil
      self.tableView.transform = blurred ? CGAffineTransform(scaleX: 0.75, y: 0.75) : .identity
      self.tableView.alpha = blurred ? 0.33 : 1.0
    }
  }
}

// MARK : - WidgetsOwnerProtocol
extension LockScreenViewController: WidgetsOwnerProtocol {
  func updatePreview(percent: CGFloat) {
    _previewAnimator?.fractionComplete = max(0.01, min(0.99, percent))
  }
  
  func finishPreview() {
    _previewAnimator?.stopAnimation(false)
    _previewAnimator?.finishAnimation(at: .end)
    _previewAnimator = nil
    AnimatorFactory.complete(view: _previewEffectView).startAnimation()
    
    blurView.effect = UIBlurEffect(style: .dark)
    blurView.isUserInteractionEnabled = true
    blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
  }
  
  func cancelPreview() {
    guard let previewAnimator = _previewAnimator else { return }
    previewAnimator.isReversed = true
    previewAnimator.startAnimation()
    previewAnimator.addCompletion {
      guard .start == $0 else { return }
      self._previewView?.removeFromSuperview()
      self._previewEffectView.removeFromSuperview()
    }
  }
  
  func startPreview(for forView: UIView) {
    _previewView?.removeFromSuperview()
    _previewView = forView.snapshotView(afterScreenUpdates: false)
    view.insertSubview(_previewView!, aboveSubview: blurView)
    _previewView?.frame = forView.convert(forView.bounds, to: view)
    _startFrame = _previewView?.frame
    addEffectView(below: _previewView!)
    _previewAnimator = AnimatorFactory.grow(view: _previewEffectView, blurView: blurView)
  }
  
  func addEffectView(below forView: UIView) {
    _previewEffectView.removeFromSuperview()
    _previewEffectView.frame = forView.frame
    
    forView.superview?.insertSubview(_previewEffectView, belowSubview: forView)
  }
  
  @objc func dismissMenu() {
    let reset = AnimatorFactory.reset(frame: _startFrame!, view: _previewEffectView, blurView: blurView)
    reset.addCompletion { [unowned self] _ in
      self._previewEffectView.removeFromSuperview()
      self._previewView?.removeFromSuperview()
      self.blurView.isUserInteractionEnabled = false
    }
    reset.startAnimation()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard _presentTransition.wantsInteractiveStart == false,
      _presentTransition.animator != nil,
      let touch = touches.first else { return }
    
    _touchesStartPointY = touch.location(in: view).y
    _presentTransition.interruptTransition()
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let startY = _touchesStartPointY,
      let touch = touches.first else { return }
    
    let currentPoint = touch.location(in: view).y
    if currentPoint < startY - 40 {
      _touchesStartPointY = nil
      _presentTransition.animator?.addCompletion { [unowned self] _ in
        self.blurView.effect = nil
      }
      _presentTransition.cancel()
    } else if currentPoint > startY + 40 {
      _touchesStartPointY = nil
      _presentTransition.finish()
    }
  }
  
}

// MARK : - UITableViewDataSource
extension LockScreenViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Footer") as! FooterCell
      cell.didPressEdit = {[unowned self] in
        self._presentTransition.wantsInteractiveStart = false
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

// MARK : - UISearchBarDelegate
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

extension LockScreenViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return _presentTransition
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return _presentTransition
  }
}

extension LockScreenViewController: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    _isDragging = true
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard _isDragging else { return }
    
    if !_isPresentingSettings && scrollView.contentOffset.y < -30 {
      _isPresentingSettings = true
      _presentTransition.wantsInteractiveStart = true
      presentSettings()
      return
    }
    
    if _isPresentingSettings {
      let progress = max(0.0, min(1.0, ((-scrollView.contentOffset.y) - 30) / 90.0))
      _presentTransition.update(progress)
    }
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let progress = max(0.0, min(1.0, ((-scrollView.contentOffset.y) - 30) / 90.0))
    
    progress > 0.5 ?
      _presentTransition.finish() : _presentTransition.cancel()
    
    _isPresentingSettings = false
    _isDragging = false
  }
}
