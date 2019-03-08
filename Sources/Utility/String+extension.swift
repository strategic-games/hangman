extension String {
  public var words: [String] {
    return self.lowercased().unicodeScalars
      .split(separator: "\n")
      .drop(while: {$0.first == "#"})
      .map {String($0.prefix(while: {$0 != " "}))}
  }
}
