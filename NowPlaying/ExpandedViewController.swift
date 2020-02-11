//
// Created by Nicolas Gonzalez on 1/31/20.
// Copyright (c) 2020 AtlasWearables. All rights reserved.
//

import UIKit

class ExpandedViewController: UIViewController {

    var button: UIButton!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if NowPlaying.shared.state == .expanding || NowPlaying.shared.state == .presenting {
            return .lightContent
        } else {
            return .default
        }
    }

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

        button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: lineHeight + lineMargin * 2))

        button.addSubview(line)
        button.addTarget(self, action: #selector(collapse), for: .touchUpInside)

        view.addSubview(button)

        view.backgroundColor = .systemGray6

    }

    @objc func collapse() {

        dismiss(animated: true)

    }

}