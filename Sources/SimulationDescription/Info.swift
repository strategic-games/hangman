import Foundation

/// Describing metadata
public struct Info {
  /// A date formatter that outputs date strings in ISO 8601 format
  static let dateFormatter = DateFormatter.ISOFormatter()
  /// A one-line description of the experiment
  let title: String
  /// More comments, descriptions, explanations
  let supplement: String?
  /// When the measurement was started
  var date: String?
  /// The build number of this software
  var version: String?
  /// A filename string composed of game, title and date
  public var filename: String {
    let message = title.split(separator: " ").joined(separator: "_")
    return "simulation_\(date!)_\(message)"
  }
}

extension Info: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    title = try container.decode(String.self, forKey: .title)
    supplement = try container.decode(String.self, forKey: .supplement)
    date = Info.dateFormatter.string(from: Date())
  }
}
