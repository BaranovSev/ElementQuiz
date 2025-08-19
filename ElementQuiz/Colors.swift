//
//  Colors.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 08.12.2023.
//

import UIKit
import Combine

enum Theme: String, CaseIterable {
    case standard = "Standard colors"
    case darkBlue = "Night blue"
    case brown = "Autumn brown"
    case violet = "Violet purple"
}

struct ThemeColors {
    let generalAppFont: UIColor
    let generalTextColor: UIColor
    let softAppColor: UIColor
    let progressBarColor: UIColor
    let salutteColor: UIColor
    let bigButtonColor: UIColor
    let secondaryTextColor: UIColor
    let periodicTableTextColor: UIColor
    let backgroundForCell: UIColor
    let alphaFontInCell: UIColor
}

private extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}

struct CustomColors {
    
    private static var currentTheme: Theme = DataManager.shared.fetchUserTheme()  {
        didSet {
            // Отправляем уведомление при изменении темы
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }
    
    static var themePublisher = NotificationCenter.default
        .publisher(for: .themeDidChange)
        .map { _ in current }
        .eraseToAnyPublisher()

    private static var current: ThemeColors { colors(for: currentTheme) }
    
    private static func color(_ name: String, fallback: UIColor = .white) -> UIColor {
            UIColor(named: name) ?? fallback
        }
    
    static private func colors(for theme: Theme) -> ThemeColors {
        switch theme {
        case .standard:
            return ThemeColors(
                generalAppFont: color("white_richBlack"),
                generalTextColor: color("oxfordBlue_lavender"),
                softAppColor: color("oxfordBlue_charcoal"),
                progressBarColor: color("gold"),
                salutteColor: color("gold"),
                bigButtonColor: color("ultraViolet"),
                secondaryTextColor: color("charcoal_lavender"),
                periodicTableTextColor: color("oxfordBlue_white"),
                backgroundForCell: color("lavender_charcoal"),
                alphaFontInCell: color("white_with_alpha")
            )
        case .darkBlue:
            return ThemeColors(
                generalAppFont: color("dark_richBlack_blackBlue"),
                generalTextColor: color("dark_columbiaBlue_airSuperiorityBlue"),
                softAppColor: color("dark_charocal_lapisLazuli"),
                progressBarColor: color("dark_gold"),
                salutteColor: color("dark_gold"),
                bigButtonColor: color("dark_ultraBlue"),
                secondaryTextColor: color("dark_airSuperiorityBlue"),
                periodicTableTextColor: color("dark_richBlack_blackBlue"), //here the same as generalAppPhont
                backgroundForCell: color("dark_charocal_oxfordBlue"),
                alphaFontInCell: color("dark_white_with_alpha")
            )
        case .brown:
            return ThemeColors(
                generalAppFont: color("brown_generalAppFont"),
                generalTextColor: color("brown_generalTextColor"),
                softAppColor: color("brown_softAppColor"),
                progressBarColor: color("brown_gold"),
                salutteColor: color("brown_gold"),
                bigButtonColor: color("brown_ultraBrown"),
                secondaryTextColor: color("brown_secondaryTextColor"),
                periodicTableTextColor: color("brown_periodicTableTextColor"),
                backgroundForCell: color("brown_backgroundForCell"),
                alphaFontInCell: color("brown_white_with_alpha")
            )
        case .violet:
            return ThemeColors(
                generalAppFont: color("violet_generalAppFont"),
                generalTextColor: color("violet_generalTextColor"),
                softAppColor: color("violet_softAppColor"),
                progressBarColor: color("violet_gold"),
                salutteColor: color("violet_gold"),
                bigButtonColor: color("violet_ultraViolet"),
                secondaryTextColor: color("violet_secondaryTextColor"),
                periodicTableTextColor: color("violet_periodicTableTextColor"),
                backgroundForCell: color("violet_backgroundForCell"),
                alphaFontInCell: color("violet_white_with_alpha")
            )
        }
    }
    
    static func colors(forPreview theme: Theme) -> ThemeColors {
        colors(for: theme)
    }

    static var softAppColor: UIColor {
        return current.softAppColor
    }
    
    static var generalTextColor: UIColor {
        return current.generalTextColor
    }
    
    static var secondaryTextColor: UIColor {
        return current.secondaryTextColor
    }
    
    static var generalAppFont: UIColor {
        return current.generalAppFont
    }
    
    static var periodicTableTextColor: UIColor {
        return current.periodicTableTextColor
    }
    
    static var backgroundForCell: UIColor {
        return current.backgroundForCell
    }
    
    static var progressBarColor: UIColor {
        return current.progressBarColor
    }
    
    static var salutteColor: UIColor {
        return current.salutteColor
    }
    
    static var alphaFontInCell: UIColor {
        return current.alphaFontInCell
    }
    
    static var bigButtonColor: UIColor {
        return current.bigButtonColor
    }
    
    static func setTheme(_ theme: Theme) {
        currentTheme = theme
        DataManager.shared.updatePreferredTheme(theme)
    }
    
    static func getCurrentTheme() -> Theme {
        return currentTheme
    }
    
    static func getRandomElementColor() -> UIColor {
        return [actinide, alkaliMetal, alkalineEarthMetal, diatomicNonmetal, lanthanide,
                metalloid, nobleGas, polyatomicNonmetal, postTransitionMetal, transitionMetal, nonmetal, halogen, unknownElement].randomElement() ?? UIColor.white
    }

    //Chemical elements colors:
    static let actinide = color("actinide")
    static let alkaliMetal = color("alkaliMetal")
    static let alkalineEarthMetal = color("alkalineEarthMetal")
    static let diatomicNonmetal = color("diatomicNonmetal")
    static let lanthanide = color("lanthanide")
    static let metalloid = color("metalloid")
    static let nobleGas = color("nobleGas")
    static let polyatomicNonmetal = color("polyatomicNonmetal")
    static let postTransitionMetal = color("postTransitionMetal")
    static let transitionMetal = color("transitionMetal")
    static let nonmetal = color("nonmetal")
    static let halogen = color("halogen")
    static let unknownElement = color("unknownElement")
    static let sblock = color("sblock")
    static let pblock = color("pblock")
    static let dblock = color("dblock")
    static let fblock = color("fblock")
    
//    technical colors
    static let greenCorrectAnswer = UIColor(red: 0.298, green: 1.0, blue: 0.298, alpha: 1.0)
    static let greenLight = UIColor(red: 0.400, green: 1.0, blue: 0.400, alpha: 1.0)
    static let redIncorrectAnswer = UIColor(red: 1.0, green: 0.298, blue: 0.298, alpha: 1.0)
    static let redLight = UIColor(red: 1.0, green: 0.400, blue: 0.400, alpha: 1.0)
}

extension CustomColors {
    static func choseColor(_ category: String) -> UIColor {
        switch category {
        case "actinide":
            return CustomColors.actinide
        case "alkali metal":
            return CustomColors.alkaliMetal
        case "alkaline earth metal":
            return CustomColors.alkalineEarthMetal
        case "diatomic nonmetal":
            return CustomColors.diatomicNonmetal
        case "lanthanide":
            return CustomColors.lanthanide
        case "metalloid":
            return CustomColors.metalloid
        case "noble gas":
            return CustomColors.nobleGas
        case "polyatomic nonmetal":
            return CustomColors.polyatomicNonmetal
        case "post-transition metal":
            return CustomColors.postTransitionMetal
        case "transition metal":
            return CustomColors.transitionMetal
        case "unknown":
            return CustomColors.unknownElement
        case "nonmetal":
            return CustomColors.nonmetal
        case "halogen":
            return CustomColors.halogen
        case "s":
            return CustomColors.sblock
        case "p":
            return CustomColors.pblock
        case "d":
            return CustomColors.dblock
        case "f":
            return CustomColors.fblock
        default:
            return UIColor.black
        }
    }
}

extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var formattedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if formattedHex.hasPrefix("#") {
            formattedHex.remove(at: formattedHex.startIndex)
        }
        
        guard formattedHex.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: formattedHex).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
