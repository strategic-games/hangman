import Foundation

extension DateFormatter {
  /// Returns a formatter which can convert between dates and strings representing dates in ISO 8601 format
  public static func ISOFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
  }
}

public extension Date {
  /// Returns a string conforming to ISO 8601 from a date
  static func ISOStringFromDate(date: Date) -> String {
    let dateFormatter = DateFormatter.ISOFormatter()
    return dateFormatter.string(from: date)
  }
  /// Parses a ISO 8601 string into a date
  static func dateFromISOString(string: String) -> Date? {
    let dateFormatter = DateFormatter.ISOFormatter()
    return dateFormatter.date(from: string)
  }
}

extension Date: LosslessStringConvertible {
  /// A date formatter for ISO 8601 format
  static let isoFormatter = DateFormatter.ISOFormatter()
  /// The date as ISO 8601 formatted string
  public var description: String {return Date.isoFormatter.string(from: self)}
  /// Initialize a date from an ISO 8601 formatted string
  public init?(_ description: String) {
    guard let date = Date.isoFormatter.date(from: description) else {return nil}
    self = date
  }
}
