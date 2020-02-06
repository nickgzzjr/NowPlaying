//
//  PlayerView.swift
//  NowPlaying
//
//  Created by Nicolas Gonzalez on 1/31/20.
//  Copyright © 2020 AtlasWearables. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {

    override public class var layerClass: Swift.AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        self.layer as! AVPlayerLayer
    }

    let player = AVPlayer()

    var loopObserver: NSObjectProtocol!
    var foregroundObserver: NSObjectProtocol!

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()

    }

    func setup() {

        backgroundColor = .clear

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill

        player.automaticallyWaitsToMinimizeStalling = true

        // Loop Video
        loopObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: nil,
                queue: .main
        ) { [weak self] _ in
            self?.player.seek(to: CMTime.zero)
            self?.player.play()
        }

        foregroundObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
        ) { [weak self] _ in
            self?.player.play()
        }

    }

    deinit {

        NotificationCenter.default.removeObserver(loopObserver as Any)
        NotificationCenter.default.removeObserver(foregroundObserver as Any)

        print("PlayerView - 💥")
    }

    func play(_ url: URL) {

        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()

    }

}

