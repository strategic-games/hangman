import Foundation

extension DateFormatter {
  static func ISOFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
  }
}

extension Date {
  static func ISOStringFromDate(date: Date) -> String {
    let dateFormatter = DateFormatter.ISOFormatter()
    return dateFormatter.string(from: date)
  }
  static func dateFromISOString(string: String) -> Date? {
    let dateFormatter = DateFormatter.ISOFormatter()
    return dateFormatter.date(from: string)
  }
}
