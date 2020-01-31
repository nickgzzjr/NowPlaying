//
//  TabBarController.swift
//  Test
//
//  Created by Nicolas Gonzalez on 1/30/20.
//  Copyright © 2020 AtlasWearables. All rights reserved.
//

import UIKit
import SnapKit
import Movin

class TabBarController: UITabBarController {

    var collapsedViewController: UIViewController!
    var collapsedView: UIView!

    var expandedViewController: UIViewController!
    var tabBarScreenshot: UIImageView!

    private var movin: Movin!
    private var isPresented: Bool = false

    var constraint: Constraint!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.isPresented {
            return .lightContent
        }
        return .default
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .fade
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in

            self.showLiveWorkout()

        }
    }

    func showLiveWorkout() {

        collapsedViewController = CollapsedViewController()
        collapsedView = collapsedViewController.view

        collapsedViewController.beginAppearanceTransition(true, animated: true)

        collapsedView.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(expand)
        ))

        view.addSubview(collapsedView)

        var heightConstraint: Constraint!

        collapsedView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            constraint = make.bottom.equalTo(tabBar.snp.top).constraint
            heightConstraint = make.height.equalTo(0).constraint
        }

        view.layoutIfNeeded()

        UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 500,
                initialSpringVelocity: 0,
                options: .curveEaseInOut,
                animations: {
                    heightConstraint.update(offset: 100)
                    self.view.layoutIfNeeded()
                }) { _ in
            self.collapsedViewController.endAppearanceTransition()
        }

        setupExpandedView()

        // Movin.isDebugPrintEnabled = true

        // Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
        //     self.expand()
        // }
        //
        // Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
        //     self.collapse()
        // }

    }

    func setupExpandedView() {

        if self.movin != nil {
            return
        }

        self.movin = Movin(1.0, TimingCurve(curve: .easeInOut, dampingRatio: 0.8))

        expandedViewController = ExpandedViewController()

        tabBarScreenshot = UIImageView(frame: self.tabBar.frame)

        self.movin!.addAnimations([
            view.mvn.cornerRadius.from(0.0).to(10.0),
            view.mvn.alpha.from(1.0).to(0.88),
            view.mvn.transform.from(CGAffineTransform(scaleX: 1.0, y: 1.0)).to(CGAffineTransform(scaleX: 0.89, y: 0.89)),
            tabBarScreenshot.mvn.point.to(CGPoint(x: 0.0, y: self.view.frame.size.height)),
            expandedViewController.view.mvn.cornerRadius.from(0.0).to(10.0),
            expandedViewController.view.mvn.frame.from(collapsedView.frame).to(CGRect(x: 0, y: 54, width: collapsedView.frame.width, height: view.frame.height - 54))
        ])

        let presentGesture = GestureAnimating(self.collapsedView, .top, self.view.frame.size)

        presentGesture.panCompletionThresholdRatio = 0.25

        let dismissGesture = GestureAnimating(expandedViewController.view, .bottom, expandedViewController.view.frame.size)

        dismissGesture.panCompletionThresholdRatio = 0.25
        dismissGesture.smoothness = 0.5

        let transition = Transition(
                movin,
                self,
                expandedViewController,
                GestureTransitioning(.present, presentGesture, dismissGesture)
        )

        transition.customContainerViewSetupHandler = { [unowned self] type, containerView in
            if type.isPresenting {
                self.setupExpand(using: containerView)
            }
            self.beginAppearanceTransition(!type.isPresenting, animated: false)
            self.expandedViewController.beginAppearanceTransition(type.isPresenting, animated: false)
        }
        transition.customContainerViewCompletionHandler = { [unowned self] type, didComplete, containerView in
            self.endAppearanceTransition()
            self.expandedViewController.endAppearanceTransition()

            if type.isDismissing {
                if didComplete {
                    print("complete dismiss")
                    self.setupCollapse(restart: true)
                } else {
                    print("cancel dismiss")
                }
            } else {
                if didComplete {
                    print("complete present")
                } else {
                    self.setupCollapse(restart: false)
                }
            }
        }

        expandedViewController.modalPresentationStyle = .overCurrentContext
        expandedViewController.transitioningDelegate = movin.configureCustomTransition(transition)

    }

    func setupExpand(using containerView: UIView) {

        expandedViewController.view.frame = collapsedView.frame

        containerView.addSubview(expandedViewController.view)

        tabBarScreenshot.image = tabBar.makeSnapshot()

        containerView.addSubview(tabBarScreenshot)

        collapsedView.isHidden = true

        isPresented = true

        setNeedsStatusBarAppearanceUpdate()

    }

    func setupCollapse(restart: Bool) {

        expandedViewController.view.removeFromSuperview()
        tabBarScreenshot.removeFromSuperview()

        collapsedView.isHidden = false

        isPresented = false

        setNeedsStatusBarAppearanceUpdate()

        if restart {
            DispatchQueue.main.async {
                self.movin = nil
                self.expandedViewController = nil
                self.setupExpandedView()
            }
        }

    }

    @objc func expand() {

        print("Expand")
        present(expandedViewController, animated: true)

    }

    @objc func collapse() {

        print("Collapse")
        expandedViewController.dismiss(animated: true)

    }

}

extension UIView {
    func makeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
