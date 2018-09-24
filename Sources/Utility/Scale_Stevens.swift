/// Scales of measurement (Stevens, 1946)
public enum ScaleStevens {
  /// Unordered categories
  case Nominal([String])
  /// Ordered categories
  case Ordinal([String])
  /// Real numbers without meaningful zero
  case Interval([Double])
  /// Real numbers with meaningful zero
  case Ratio([Double])
}

extension ScaleStevens: Codable {
  private enum CodingKeys: CodingKey {
    case nominal, ordinal, interval, ratio
  }
  /// Encode a scale to an encoder
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .Nominal(let values):
      try container.encode(values, forKey: .nominal)
    case .Ordinal(let values):
      try container.encode(values, forKey: .ordinal)
    case .Interval(let values):
      try container.encode(values, forKey: .interval)
    case .Ratio(let values):
      try container.encode(values, forKey: .ratio)
    }
  }
  /// Initialize a scale from a decoder
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let values = try? container.decode([String].self, forKey: .nominal) {
      self = .Nominal(values)
    } else if let values = try? container.decode([String].self, forKey: .ordinal) {
      self = .Ordinal(values)
    } else if let values = try? container.decode([Double].self, forKey: .interval) {
      self = .Interval(values)
    } else {
      let values = try container.decode([Double].self, forKey: .ratio)
      self = .Ratio(values)
    }
  }
}
