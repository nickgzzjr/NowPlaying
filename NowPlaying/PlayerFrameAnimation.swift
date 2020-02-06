//
// Created by Nicolas Gonzalez on 2/5/20.
// Copyright (c) 2020 AtlasWearables. All rights reserved.
//

import Movin

public final class PlayerFrameAnimation: ValueAnimationCompatible {

    public func beforeAnimation(_ isForward: Bool) {
        currentValue = isForward ? fromValue : toValue
    }

    public func animate(_ animationDirection: AnimationDirection) {
        // Make sure not to run anything during animation...
    }

    public func interactiveAnimate(_ isForward: Bool, _ fractionComplete: CGFloat) {

        guard fractionComplete >= 0 else {
            return
        }

        let current: CGFloat

        if isForward {
            current = fractionComplete
        } else {
            current = 1 - fractionComplete
        }

        func convert(_ from: CGFloat, _ to: CGFloat) -> CGFloat {
            (to - from) * current + from
        }

        // print(convert(fromValue.minY, toValue.minY))

        currentValue = CGRect(
                x: convert(fromValue.minX, toValue.minX),
                y: convert(fromValue.minY, toValue.minY),
                width: convert(fromValue.width, toValue.width),
                height: convert(fromValue.height, toValue.height)
        )
    }

    public func finishInteractiveAnimation(_ interactiveTransitioning: InteractiveTransitioning) {

        let completed = interactiveTransitioning.transition.movin.animator.fractionComplete

        let duration = Double(interactiveTransitioning.duration * (1.0 - completed))

        UIView.animate(withDuration: duration) {
            if interactiveTransitioning.type.isPresenting {
                if interactiveTransitioning.isCompleted {
                    self.currentValue = self.toValue
                } else {
                    self.currentValue = self.fromValue
                }
            } else {
                if interactiveTransitioning.isCompleted {
                    self.currentValue = self.fromValue
                } else {
                    self.currentValue = self.toValue
                }
            }
        }

    }

    public typealias Value = CGRect

    public let view: UIView

    public var delayFactor: CGFloat = 0
    public var fromValue: Value
    public var toValue: Value
    public var fromTimeInterval = 0.0
    public var toTimeInterval = 1.0
    public var currentValue: Value {
        didSet {
            self.view.frame = self.currentValue
        }
    }

    deinit {
        Movin.dp("FrameAnimation - deinit")
    }

    public init(_ view: UIView) {
        self.view = view

        self.fromValue = view.frame
        self.toValue = view.frame
        self.currentValue = self.fromValue
    }

}