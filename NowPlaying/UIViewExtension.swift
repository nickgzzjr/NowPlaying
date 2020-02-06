//
// Created by Nicolas Gonzalez on 2/6/20.
// Copyright (c) 2020 AtlasWearables. All rights reserved.
//

import UIKit

extension UIView {

    func makeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}