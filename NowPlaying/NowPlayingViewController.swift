//
// Created by Nicolas Gonzalez on 4/30/20.
// Copyright (c) 2020 AtlasWearables. All rights reserved.
//

import UIKit

class NowPlayingViewController: UIViewController {

    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var contentView: UIView!

    var contentViewFrame: CGRect {
        .zero
    }
    var playerViewFrame: CGRect {
        .zero
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

    }


}