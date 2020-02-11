//
//  LiveWorkoutViewController.swift
//  Test
//
//  Created by Nicolas Gonzalez on 1/30/20.
//  Copyright © 2020 AtlasWearables. All rights reserved.
//

import UIKit

class CollapsedViewController: UIViewController {

    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var contentView: UIView!

    var showingVideo = true

    deinit {
        print("CollapsedViewController - 💥")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6

        playerView.play(URL(fileReferenceLiteralResourceName: "video.mp4"))

    }

}
