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

    // private var isPresented: Bool = false

    // override var preferredStatusBarStyle: UIStatusBarStyle {
    //     if self.isPresented {
    //         return .lightContent
    //     }
    //     return .default
    // }

    // override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    //     .fade
    // }

    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            NowPlaying.shared.show(using: self)
            Timer.scheduledTimer(withTimeInterval: 1.1, repeats: false) { _ in
                NowPlaying.shared.expand()
                Timer.scheduledTimer(withTimeInterval: 1.1, repeats: false) { _ in
                    NowPlaying.shared.collapse()
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        NowPlaying.shared.hide()
                    }
                }
            }
        }

    }

}

public extension MovinExtensionCompatibleWrapped where Base: UIView {

    var playerFrame: PlayerFrameAnimation {
        PlayerFrameAnimation(self.base)
    }

    var frameInteractive: FrameKeyframeInteractiveAnimation {
        FrameKeyframeInteractiveAnimation(self.base)
    }

}
