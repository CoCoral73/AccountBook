//
//  Extension.swift
//  AccountBook
//
//  Created by 김정원 on 8/2/25.
//

import UIKit

extension Formatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "," // 한국어에선 기본이긴 함
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

extension Int64 {
    var formattedWithComma: String {
        return Formatter.currency.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -7.5, 7.5, -5.0, 5.0, -2.5, 2.5, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    func generateFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

extension Character {
    var isEmoji: Bool {
        return unicodeScalars.contains { $0.properties.isEmoji }
    }
}

extension String {
    //이모지 -> 이미지
    func toImage(withDimension dimension: CGFloat = 40, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        // Create a UILabel to hold the emoji
        let label = UILabel()
        label.text = self // Set the emoji as the label's text
        label.font = UIFont.systemFont(ofSize: dimension) // Set a large font size for clarity
        label.sizeToFit() // Adjust label size to fit the content

        // Begin an image context with the label's bounds and the desired scale
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, scale)

        // Render the label's layer into the current image context
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in: context)

        // Get the image from the context
        let image = UIGraphicsGetImageFromCurrentImageContext()

        // End the image context
        UIGraphicsEndImageContext()

        return image
    }
}
