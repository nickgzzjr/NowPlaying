//
// Created by Nicolas Gonzalez on 2/5/20.
// Copyright (c) 2020 AtlasWearables. All rights reserved.
//

import Movin
import SnapKit

class NowPlaying {

    static var shared: NowPlaying = NowPlaying()

    let collapsedViewController: CollapsedViewController
    let expandedViewController: ExpandedViewController

    enum State {
        case appearing
        case showing
        case disappearing
        case hiding
    }

    var state: State = .hiding

    var tabBarController: TabBarController!

    var movin: Movin!

    var tabBarScreenshot: UIImageView!
    var expandedViewDestination: CGRect!

    var heightConstraint: Constraint!

    deinit {
        print("CollapsedExpandedTransition - 💥")
    }

    init() {

        expandedViewController = ExpandedViewController()

        collapsedViewController = UIStoryboard(
                name: "Main",
                bundle: nil
        ).instantiateViewController(
                withIdentifier: "CollapsedViewController"
        ) as! CollapsedViewController

        collapsedViewController.view.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(expand)
        ))

    }

    func show(using tabBarController: TabBarController) {

        self.tabBarController = tabBarController

        guard state == .hiding else {
            print("Error: Cannot show because the state is not hiding....")
            return
        }

        state = .appearing

        tabBarController.view.insertSubview(collapsedViewController.view, at: 1)

        collapsedViewController.view.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.bottom.equalTo(tabBarController.tabBar.snp.top)
            if self.heightConstraint == nil {
                self.heightConstraint = make.height.equalTo(0).constraint
            }
        }

        tabBarController.view.layoutIfNeeded()

        UIView.animate(
                withDuration: 1.0,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.heightConstraint.update(offset: 80)
                    tabBarController.view.layoutIfNeeded()
                },
                completion: { _ in
                    self.state = .showing
                    self.collapsedViewController.endAppearanceTransition()
                })

        collapsedViewController.beginAppearanceTransition(true, animated: true)

        setupExpandedView()

    }

    func hide() {

        guard state == .showing else {
            print("Error: Cannot hide because the state is not showing....")
            return
        }

        state = .disappearing

        UIView.animate(
                withDuration: 1.0,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.heightConstraint.update(offset: 0)
                    self.tabBarController.view.layoutIfNeeded()
                },
                completion: { _ in
                    self.state = .hiding
                    self.collapsedViewController.endAppearanceTransition()
                    self.collapsedViewController.view.removeFromSuperview()
                })

        collapsedViewController.beginAppearanceTransition(false, animated: true)

    }

    @objc func expand(_ sender: UITapGestureRecognizer) {

        tabBarController.present(expandedViewController, animated: true)

    }

    func setupExpandedView() {

        if self.movin != nil {
            return
        }

        self.movin = Movin(1.0, TimingCurve())

        tabBarScreenshot = UIImageView(frame: tabBarController.tabBar.frame)

        let frameWidth = collapsedViewController.view.frame.width

        expandedViewDestination = CGRect(x: 0, y: 54, width: frameWidth, height: tabBarController.view.frame.height - 54)

        let playerWidth = frameWidth
        let playerHeight = playerWidth * 9 / 16
        let playerDestination = CGRect(x: 0, y: 35, width: playerWidth, height: playerHeight)

        let contentWidth = frameWidth - 40
        let contentHeight = collapsedViewController.contentView.frame.height
        let contentDestination = CGRect(x: 20, y: playerHeight + 55, width: contentWidth, height: contentHeight)

        self.movin.addAnimations([
            tabBarController.view.mvn.cornerRadius.from(0.0).to(10.0),
            tabBarController.view.mvn.alpha.from(1.0).to(0.88),
            tabBarController.view.mvn.transform.from(CGAffineTransform(scaleX: 1.0, y: 1.0)).to(CGAffineTransform(scaleX: 0.89, y: 0.89)),
            tabBarScreenshot.mvn.point.to(CGPoint(x: 0.0, y: tabBarController.view.frame.size.height)),
            expandedViewController.view.mvn.cornerRadius.from(0.0).to(10.0),
            expandedViewController.view.mvn.frame.from(collapsedViewController.view.frame).to(expandedViewDestination),
            expandedViewController.button.mvn.alpha.from(-1).to(1),
            collapsedViewController.playerView.mvn.playerFrame.from(collapsedViewController.playerView.frame).to(playerDestination),
            collapsedViewController.contentView.mvn.frameInteractive
                    .from(collapsedViewController.contentView.frame)
                    .keyframe(
                            duration: 0.1,
                            x: collapsedViewController.contentView.frame.minX,
                            y: contentDestination.minY / 3,
                            width: collapsedViewController.contentView.frame.width
                    )
                    .to(contentDestination),
        ])

        let presentGesture = GestureAnimating(self.collapsedViewController.view, .top, tabBarController.view.frame.size)

        presentGesture.panCompletionThresholdRatio = 0.25

        let dismissGesture = GestureAnimating(expandedViewController.view, .bottom, tabBarController.view.frame.size)

        dismissGesture.panCompletionThresholdRatio = 0.25
        dismissGesture.smoothness = 0.5

        let gestures = GestureTransitioning(.present, presentGesture, dismissGesture)

        let transition = Transition(movin, tabBarController, expandedViewController, gestures)

        transition.customContainerViewSetupHandler = setupExpand
        transition.customContainerViewCompletionHandler = completeCollapse

        expandedViewController.modalPresentationStyle = .overCurrentContext
        expandedViewController.transitioningDelegate = movin.configureCustomTransition(transition)

    }

    func setupExpand(_ type: TransitionType, _ containerView: UIView) {
        if type.isPresenting {
            // collapsedConstraints = collapsedViewController.view.constraints

            expandedViewController.view.frame = collapsedViewController.view.frame
            expandedViewController.view.frame = expandedViewDestination
            expandedViewController.view.addSubview(collapsedViewController.playerView)

            // NSLayoutConstraint.deactivate(collapsedViewController.contentView.constraints)
            expandedViewController.view.addSubview(collapsedViewController.contentView)

            containerView.addSubview(expandedViewController.view)

            tabBarScreenshot.image = tabBarController.tabBar.makeSnapshot()

            containerView.addSubview(tabBarScreenshot)

            collapsedViewController.view.isHidden = true

            // isPresented = true

            // setNeedsStatusBarAppearanceUpdate()
        }
        tabBarController.beginAppearanceTransition(!type.isPresenting, animated: false)
        self.expandedViewController.beginAppearanceTransition(type.isPresenting, animated: false)
    }

    func completeCollapse(_ type: TransitionType, _ didComplete: Bool, _ containerView: UIView) {
        tabBarController.endAppearanceTransition()
        self.expandedViewController.endAppearanceTransition()

        if type.isDismissing {
            if didComplete {
                print("complete dismiss")
                self.completeCollapse(restart: true)
            } else {
                print("cancel dismiss")
            }
        } else {
            if didComplete {
                print("complete present")
            } else {
                print("cancel present")
                self.completeCollapse(restart: false)
            }
        }
    }

    func completeCollapse(restart: Bool) {

        tabBarController.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

        expandedViewController.view.removeFromSuperview()
        tabBarScreenshot.removeFromSuperview()

        collapsedViewController.view.addSubview(collapsedViewController.playerView)
        collapsedViewController.view.addSubview(collapsedViewController.contentView)

        // NSLayoutConstraint.activate(collapsedConstraints)

        collapsedViewController.view.isHidden = false

        // isPresented = false

        // setNeedsStatusBarAppearanceUpdate()

        if restart {
            DispatchQueue.main.async {
                self.movin = nil
                self.setupExpandedView()
            }
        }

    }

}
