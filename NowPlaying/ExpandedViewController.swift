//
// Created by Nicolas Gonzalez on 1/31/20.
// Copyright (c) 2020 AtlasWearables. All rights reserved.
//

import UIKit
import SnapKit

class ExpandedViewController: NowPlayingViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if NowPlaying.shared.state == .expanding || NowPlaying.shared.state == .presenting {
            return .lightContent
        } else {
            return .default
        }
    }

    override var contentViewFrame: CGRect {

        CGRect(
                x: 0,
                y: playerHeight + 55,
                width: UIScreen.main.bounds.width,
                height: contentView.frame.height
        )

    }

    override var playerViewFrame: CGRect {

        CGRect(
                x: 0,
                y: 35,
                width: UIScreen.main.bounds.width,
                height: playerHeight
        )

    }

    var scrollViewFrame: CGRect {

        let y = contentView.frame.height + playerHeight + 65

        return CGRect(
                x: 0,
                y: y,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height - top - y
        )

    }

    var playerHeight: CGFloat {
        let playerHeight: CGFloat
        if NowPlaying.shared.showingVideo {
            playerHeight = UIScreen.main.bounds.width * 9 / 16
        } else {
            playerHeight = 0
        }
        return playerHeight
    }

    let top: CGFloat = 54
    let button = UIButton()
    let detailsView = UIView()

    var constraint: Constraint?

    deinit {
        print("ExpandedViewController - 💥")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let lineWidth: CGFloat = 36
        let lineHeight: CGFloat = 5
        let lineX = view.frame.width / 2 - lineWidth / 2
        let lineMargin: CGFloat = 15

        let line = UIView(frame: CGRect(x: lineX, y: 15, width: lineWidth, height: lineHeight))

        line.isUserInteractionEnabled = false
        line.backgroundColor = .systemFill
        line.layer.cornerRadius = lineHeight / 2

        button.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: lineHeight + lineMargin * 2)

        button.addSubview(line)
        button.addTarget(self, action: #selector(collapse), for: .touchUpInside)

        view.addSubview(button)

        view.backgroundColor = .systemGray6

        detailsView.frame = CGRect(x: 0, y: 300, width: view.frame.width, height: view.frame.height - 300)
        detailsView.backgroundColor = .green
        view.addSubview(detailsView)

        let randomView = UIView()
        randomView.backgroundColor = .red
        detailsView.addSubview(randomView)
        randomView.snp.makeConstraints { make in
            make.height.centerY.width.centerX.equalToSuperview()
        }

    }

    @objc func collapse() {

        dismiss(animated: true)

    }

}