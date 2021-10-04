// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum Buttons {
    /// Add more cities
    internal static let addCities = L10n.tr("Localizable", "Buttons.addCities")
  }

  internal enum City {
    /// Chosen cities
    internal static let chosenCities = L10n.tr("Localizable", "City.chosenCities")
    /// Find city
    internal static let find = L10n.tr("Localizable", "City.find")
    /// Unknown city
    internal static let unknown = L10n.tr("Localizable", "City.unknown")
    /// Your city
    internal static let yourCityTitle = L10n.tr("Localizable", "City.yourCityTitle")
  }

  internal enum Controls {
    /// Done
    internal static let done = L10n.tr("Localizable", "Controls.done")
  }

  internal enum Screens {
    /// Choose your cities
    internal static let choosingCitiesTitle = L10n.tr("Localizable", "Screens.choosingCitiesTitle")
    /// Daily forecast
    internal static let dailyScreenTitle = L10n.tr("Localizable", "Screens.dailyScreenTitle")
    /// Your cities
    internal static let mainTitle = L10n.tr("Localizable", "Screens.mainTitle")
    /// New city
    internal static let newCity = L10n.tr("Localizable", "Screens.newCity")
  }

  internal enum Weather {
    /// Current
    internal static let current = L10n.tr("Localizable", "Weather.current")
    /// deg.
    internal static let units = L10n.tr("Localizable", "Weather.units")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
