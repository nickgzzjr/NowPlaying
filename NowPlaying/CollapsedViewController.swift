//
//  LiveWorkoutViewController.swift
//  Test
//
//  Created by Nicolas Gonzalez on 1/30/20.
//  Copyright © 2020 AtlasWearables. All rights reserved.
//

import UIKit

class CollapsedViewController: NowPlayingViewController {

    override var contentViewFrame: CGRect {

        CGRect(
                x: x,
                y: 0,
                width: UIScreen.main.bounds.width - x,
                height: height
        )

    }

    override var playerViewFrame: CGRect {

        CGRect(
                x: x - playerViewWidth,
                y: 0,
                width: playerViewWidth,
                height: height
        )

    }

    var x: CGFloat {

        let x: CGFloat

        if NowPlaying.shared.showingVideo {
            x = playerViewWidth
        } else {
            x = 0
        }

        return x

    }

    var playerViewWidth: CGFloat = 107
    var height: CGFloat = 60

    override func viewDidLoad() {
        super.viewDidLoad()

        playerView.play(URL(fileReferenceLiteralResourceName: "video.mp4"))

    }

}
