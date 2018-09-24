/// Scales of measurement (Mosteller & Tukey, 1977)
public enum ScaleTukey {
  /// Unordered labels
  case Names([String])
  /// Ordered labels
  case Grades([String])
  /// Orders, integer values starting from 1
  case Ranks([Int])
  /// Number values Bound by 0 and 1
  case CountedFractions([Double])
  /// Non-negative integers
  case Counts([Int])
  /// Non-negative real numbers
  case Amounts([Double])
  /// Real numbers
  case Balances([Double])
}

extension ScaleTukey: Codable {
  private enum CodingKeys: CodingKey {
    case names, grades, ranks, counted_fractions, counts, amounts, balances
  }
  /// Encode a scale to an encoder
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .Names(let values):
      try container.encode(values, forKey: .names)
    case .Grades(let values):
      try container.encode(values, forKey: .grades)
    case .Ranks(let values):
      try container.encode(values, forKey: .ranks)
    case .CountedFractions(let values):
      try container.encode(values, forKey: .counted_fractions)
    case .Counts(let values):
      try container.encode(values, forKey: .counts)
    case .Amounts(let values):
      try container.encode(values, forKey: .amounts)
    case .Balances(let values):
      try container.encode(values, forKey: .balances)
    }
  }
  /// Initialize a scale from a decoder
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let values = try? container.decode([String].self, forKey: .names) {
      self = .Names(values)
    } else if let values = try? container.decode([String].self, forKey: .grades) {
      self = .Grades(values)
    } else if let values = try? container.decode([Int].self, forKey: .ranks) {
      self = .Ranks(values)
    } else if let values = try? container.decode([Double].self, forKey: .counted_fractions) {
      self = .CountedFractions(values)
    } else if let values = try? container.decode([Int].self, forKey: .counts) {
      self = .Counts(values)
    } else if let values = try? container.decode([Double].self, forKey: .amounts) {
      self = .Amounts(values)
    } else {
      let values = try container.decode([Double].self, forKey: .balances)
      self = .Balances(values)
    }
  }
}
