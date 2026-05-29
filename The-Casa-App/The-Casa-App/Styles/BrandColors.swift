import SwiftUI
import UIKit

struct BrandColors {
    // MARK: - SwiftUI Colors
    static let background = Color(hex: "FFF9F2")
    static let primaryBrand = Color(hex: "4B2C20")
    static let primaryText = Color(hex: "4B2C20")
    static let accent = Color(hex: "A78D78")
    static let darkContrast = Color(hex: "2C3639")
    static let rating = Color(red: 0.72, green: 0.45, blue: 0.20)
    
    // MARK: - UIKit Colors
    static let backgroundUI = UIColor(hex: "FFF9F2")
    static let primaryBrandUI = UIColor(hex: "4B2C20")
    static let primaryTextUI = UIColor(hex: "4B2C20")
    static let accentUI = UIColor(hex: "A78D78")
    static let darkContrastUI = UIColor(hex: "2C3639")
}

// MARK: - Hex Helpers
extension Color {
    init(hex: String) {
        let rgba = Color.parseHex(hex)
        self.init(.sRGB, red: rgba.r, green: rgba.g, blue: rgba.b, opacity: rgba.a)
    }
    
    static func parseHex(_ hex: String) -> (r: Double, g: Double, b: Double, a: Double) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        return (Double(r) / 255, Double(g) / 255, Double(b) / 255, Double(a) / 255)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let rgba = Color.parseHex(hex)
        self.init(red: CGFloat(rgba.r), green: CGFloat(rgba.g), blue: CGFloat(rgba.b), alpha: CGFloat(rgba.a))
    }
}
