//
//  Extension.swift
//  AccountBook
//
//  Created by 김정원 on 8/2/25.
//

import UIKit

extension Date {
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        let calendar = Calendar.current
        // 다음 달의 1일을 구한 다음 하루 전으로 이동
        guard let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth),
              let endOfMonth = calendar.date(byAdding: .second, value: -1, to: startOfNextMonth)
        else { fatalError("Date 계산 실패") }
        return endOfMonth
    }
    
    var kstString: String {
        let fmt = DateFormatter()
        fmt.timeZone = TimeZone(identifier: "Asia/Seoul")
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy년 MM월 dd일 EEEE HH시 mm분 ss초"
        return fmt.string(from: self)
    }
}

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
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get { layer.cornerRadius }
    }
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get { layer.borderWidth }
    }
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let cgColor = layer.borderColor else { return nil }
            return UIColor(cgColor: cgColor)
        }
    }
    
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
