/// Scales of measurement (Mosteller & Tukey, 1977)
public enum ScaleTukey {
  /// Unordered labels
  case names([String])
  /// Ordered labels
  case grades([String])
  /// Orders, integer values starting from 1
  case ranks([Int])
  /// Number values Bound by 0 and 1
  case countedFractions([Double])
  /// Non-negative integers
  case counts([Int])
  /// Non-negative real numbers
  case amounts([Double])
  /// Real numbers
  case balances([Double])
}
