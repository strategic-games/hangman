/// Scales of measurement (Stevens, 1946)
public enum ScaleStevens {
  /// Unordered categories
  case nominal([String])
  /// Ordered categories
  case ordinal([String])
  /// Real numbers without meaningful zero
  case interval([Double])
  /// Real numbers with meaningful zero
  case ratio([Double])
}
