//
// Created by Nicolas Gonzalez on 1/31/20.
// Copyright (c) 2020 AtlasWearables. All rights reserved.
//

import UIKit

class ExpandedViewController: UIViewController {

    deinit {
        print("💥")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))

        button.addTarget(self, action: #selector(collapse), for: .touchUpInside)
        button.setTitle("Collapse", for: .normal)

        view.addSubview(button)

    }

    @objc func collapse() {

        dismiss(animated: true)

    }
}