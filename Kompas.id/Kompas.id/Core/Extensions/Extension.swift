//
//  Helpers.swift
//  Kompas.id
//
//  Created by Farhan on 07/08/25.
//

import UIKit

extension UIColor {
    static func fromHex(_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension String {
    /// Convert string to a URL-friendly slug: lowercased, remove diacritics, replace non-alphanumerics with hyphens, collapse repeats
    func slugified() -> String {
        let lower = self.lowercased()
        let noDiacritics = lower.folding(options: .diacriticInsensitive, locale: .current)
        let allowed = noDiacritics.unicodeScalars.map { scalar -> Character in
            if CharacterSet.alphanumerics.contains(scalar) {
                return Character(scalar)
            } else {
                return " "
            }
        }
        let spaced = String(allowed)
        let components = spaced.split { $0.isWhitespace }
        let joined = components.joined(separator: "-")
        let trimmed = joined.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return trimmed
    }
}

extension UIApplication {
    static func currentKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    static func topMostViewController(from base: UIViewController? = UIApplication.currentKeyWindow()?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(from: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMostViewController(from: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(from: presented)
        }
        return base
    }
}
