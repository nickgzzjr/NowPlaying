//
// Created by Nicolas Gonzalez on 2/5/20.
// Copyright (c) 2020 AtlasWearables. All rights reserved.
//

import Movin

public final class FrameKeyframeInteractiveAnimation: ValueAnimationCompatible {

    public func beforeAnimation(_ isForward: Bool) {

        currentValue = isForward ? fromValue : toValue

        animator = UIViewPropertyAnimator(duration: 1.0, timingParameters: TimingCurve())

        animator.addAnimations({

            UIView.animateKeyframes(
                    withDuration: 1.0,
                    delay: 0.0,
                    animations: {

                        var x = self.currentValue.minX
                        var y = self.currentValue.minY
                        var width = self.currentValue.width
                        var height = self.currentValue.height
                        var start = 0.0

                        var keyframes = self.keyframes

                        if !isForward {
                            keyframes.reverse()
                        }

                        for keyframe in keyframes {

                            var duration = keyframe.duration

                            if !isForward {
                                duration = 1 - duration
                            }

                            UIView.addKeyframe(
                                    withRelativeStartTime: start,
                                    relativeDuration: duration
                            ) {

                                if let keyframeX = keyframe.x {
                                    x = keyframeX
                                }
                                if let keyframeY = keyframe.y {
                                    y = keyframeY
                                }
                                if let keyframeWidth = keyframe.width {
                                    width = keyframeWidth
                                }
                                if let keyFrameHeight = keyframe.height {
                                    height = keyFrameHeight
                                }

                                self.currentValue = CGRect(x: x, y: y, width: width, height: height)

                            }

                            start += duration

                        }

                        UIView.addKeyframe(
                                withRelativeStartTime: start,
                                relativeDuration: 1 - start
                        ) {

                            if isForward {
                                self.currentValue = self.toValue
                            } else {
                                self.currentValue = self.fromValue
                            }

                        }

                    })

        })

    }

    public func animate(_ animationDirection: AnimationDirection) {
    }

    public func interactiveAnimate(_ isForward: Bool, _ fractionComplete: CGFloat) {

        guard animator != nil else {
            return
        }

        animator.fractionComplete = fractionComplete

    }

    public func finishInteractiveAnimation(_ interactiveTransitioning: InteractiveTransitioning) {

        animator.isReversed = !interactiveTransitioning.isCompleted
        animator.startAnimation()

    }

    public typealias Value = CGRect

    public let view: UIView

    struct Keyframe {

        let duration: Double
        let x: CGFloat?
        let y: CGFloat?
        let width: CGFloat?
        let height: CGFloat?

    }

    var keyframes = [Keyframe]()

    var animator: UIViewPropertyAnimator!

    public var delayFactor: CGFloat = 0
    public var fromValue: Value
    public var toValue: Value
    public var currentValue: Value {
        didSet {
            self.view.frame = self.currentValue
        }
    }

    deinit {
        print("💥")
    }

    public init(_ view: UIView) {
        self.view = view

        self.fromValue = view.frame
        self.toValue = view.frame
        self.currentValue = view.frame

    }

    func keyframe(
            duration: Double = 1.0,
            x: CGFloat? = nil,
            y: CGFloat? = nil,
            width: CGFloat? = nil,
            height: CGFloat? = nil
    ) -> FrameKeyframeInteractiveAnimation {
        keyframes.append(Keyframe(
                duration: duration,
                x: x,
                y: y,
                width: width,
                height: height
        ))
        return self
    }

}
