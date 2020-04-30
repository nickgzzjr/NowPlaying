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
        case expanding
        case presenting
        case collapsing
        case disappearing
        case hiding
    }

    var state: State = .hiding

    var tabBarController: TabBarController!
    var movin: Movin!
    var tabBarScreenshot: UIImageView!
    var expandedViewDestination: CGRect!
    var heightConstraint: Constraint!
    let showingVideo = true
    var duration = 0.5

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

        expandedViewController.playerView = collapsedViewController.playerView
        expandedViewController.contentView = collapsedViewController.contentView

    }

    func show(using tabBarController: TabBarController) {

        self.tabBarController = tabBarController

        guard state == .hiding else {
            print("Error: Cannot show because the state is not hiding....")
            return
        }

        state = .appearing

        tabBarController.view.insertSubview(collapsedViewController.view, at: 1)

        tabBarScreenshot = UIImageView(frame: tabBarController.tabBar.frame)

        tabBarScreenshot.layer.shadowOpacity = 0.3
        tabBarScreenshot.layer.shadowRadius = 0
        tabBarScreenshot.layer.shadowOffset = CGSize(width: 0, height: -0.333)
        tabBarScreenshot.layer.shadowColor = UIColor.systemFill.cgColor
        tabBarScreenshot.layer.masksToBounds = false

        collapsedViewController.view.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.bottom.equalTo(tabBarController.tabBar.snp.top)
            if self.heightConstraint == nil {
                self.heightConstraint = make.height.equalTo(0).constraint
            }
        }

        tabBarController.view.layoutIfNeeded()

        UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.heightConstraint.update(offset: 60)
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
                withDuration: duration,
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

    @objc func expand() {

        tabBarController.present(expandedViewController, animated: true)

    }

    func collapse() {

        expandedViewController.collapse()

    }

    func setupExpandedView() {

        if self.movin != nil {
            return
        }

        self.movin = Movin(duration, TimingCurve())

        let frameWidth = tabBarController.view.frame.width
        let frameHeight = tabBarController.view.frame.height

        let sourceView = tabBarController.view!

        var animations: [AnimationCompatible] = [
            sourceView.mvn.cornerRadius
                    .from(0.0)
                    .to(10.0),
            sourceView.mvn.alpha
                    .from(1.0)
                    .to(0.88),
            sourceView.mvn.transform
                    .from(CGAffineTransform(scaleX: 1.0, y: 1.0))
                    .to(CGAffineTransform(scaleX: 0.89, y: 0.89)),
            tabBarScreenshot.mvn.point
                    .from(tabBarController.tabBar.frame.origin)
                    .to(CGPoint(x: 0.0, y: frameHeight)),
            expandedViewController.view.mvn.cornerRadius
                    .from(0.0)
                    .to(10.0),
            expandedViewController.view.mvn.frame
                    .from(CGRect(
                            origin: collapsedViewController.view.frame.origin,
                            size: CGSize(
                                    width: frameWidth,
                                    height: frameHeight - collapsedViewController.view.frame.minY
                            )
                    ))
                    .to(CGRect(
                            x: 0,
                            y: expandedViewController.top,
                            width: frameWidth,
                            height: frameHeight - expandedViewController.top
                    )),
            expandedViewController.button.mvn.alpha
                    .from(-1)
                    .to(1),
            expandedViewController.detailsView.mvn.alpha
                    .from(-1)
                    .to(1)
        ]

        if showingVideo {

            animations += [
                collapsedViewController.playerView.mvn.playerFrame
                        .from(collapsedViewController.playerViewFrame)
                        .to(expandedViewController.playerViewFrame)
            ]

            let contentOrigin = collapsedViewController.contentViewFrame
            let contentDestination = expandedViewController.contentViewFrame

            animations += [
                collapsedViewController.contentView.mvn.frameInteractive
                        .from(contentOrigin)
                        .keyframe(
                                duration: 0.1,
                                x: contentOrigin.minX,
                                y: contentDestination.minY / 3,
                                width: contentOrigin.width
                        )
                        .to(contentDestination)
            ]

        } else {

            animations += [
                collapsedViewController.contentView.mvn.frame
                        .from(collapsedViewController.contentViewFrame)
                        .to(expandedViewController.contentViewFrame)
            ]

        }

        animations += [
            expandedViewController.detailsView.mvn.playerFrame
                    .from(CGRect(x: 0, y: frameHeight, width: frameWidth, height: 0))
                    .to(expandedViewController.scrollViewFrame)
        ]

        self.movin.addAnimations(animations)

        let presentGesture = GestureAnimating(self.collapsedViewController.view, .top, UIScreen.main.bounds.size)

        presentGesture.panCompletionThresholdRatio = 0.25

        let dismissGesture = GestureAnimating(expandedViewController.view, .bottom, UIScreen.main.bounds.size)

        dismissGesture.panCompletionThresholdRatio = 0.25
        dismissGesture.smoothness = 0.5

        let gestures = GestureTransitioning(state == .presenting ? .dismiss : .present, presentGesture, dismissGesture)

        let transition = Transition(movin, tabBarController, expandedViewController, gestures)

        transition.customContainerViewSetupHandler = setupTransition
        transition.customContainerViewCompletionHandler = completeTransition

        expandedViewController.modalPresentationStyle = .overCurrentContext
        expandedViewController.modalPresentationCapturesStatusBarAppearance = true
        expandedViewController.transitioningDelegate = movin.configureCustomTransition(transition)

    }

    func setupTransition(_ type: TransitionType, _ containerView: UIView) {
        if type.isPresenting {

            state = .expanding

            // collapsedConstraints = collapsedViewController.view.constraints
            expandedViewController.setNeedsStatusBarAppearanceUpdate()
            expandedViewController.view.frame = collapsedViewController.view.frame
            expandedViewController.view.addSubview(collapsedViewController.playerView)

            // NSLayoutConstraint.deactivate(collapsedViewController.contentView.constraints)
            expandedViewController.view.addSubview(collapsedViewController.contentView)

            containerView.addSubview(expandedViewController.view)

            tabBarScreenshot.image = tabBarController.tabBar.makeSnapshot()

            containerView.addSubview(tabBarScreenshot)

            collapsedViewController.view.isHidden = true

        } else {
            state = .collapsing
        }
        tabBarController.beginAppearanceTransition(!type.isPresenting, animated: true)
        self.expandedViewController.beginAppearanceTransition(type.isPresenting, animated: true)
    }

    func completeTransition(_ type: TransitionType, _ didComplete: Bool, _ containerView: UIView) {
        tabBarController.endAppearanceTransition()
        self.expandedViewController.endAppearanceTransition()

        if type.isDismissing {
            if didComplete {
                print("complete dismiss")
                state = .showing
                self.completeCollapse(restart: true)
            } else {
                print("cancel dismiss")
                state = .presenting
            }
        } else {
            if didComplete {
                print("complete present")
                state = .presenting
            } else {
                print("cancel present")
                state = .showing
                self.completeCollapse(restart: true)
            }
        }
    }

    func completeCollapse(restart: Bool) {

        expandedViewController.setNeedsStatusBarAppearanceUpdate()
        expandedViewController.view.removeFromSuperview()
        tabBarScreenshot.removeFromSuperview()

        collapsedViewController.view.addSubview(collapsedViewController.playerView)
        collapsedViewController.view.addSubview(collapsedViewController.contentView)

        // NSLayoutConstraint.activate(collapsedConstraints)

        collapsedViewController.view.isHidden = false

        if restart {
            DispatchQueue.main.async {
                self.reset()
            }
        }

    }

    func reset() {

        self.movin = nil
        self.setupExpandedView()

    }

}