import Utility

public struct BegriffixBoard {
  /// The type of a letter, can be written at one board position
  public typealias Letter = Unicode.Scalar
  /// The type of a word which is a sequence of letters
  public typealias Word = [Letter]
  /// The value of a field, can be a letter or nil
  public typealias Field = Letter?
  /// A sequence of optional letters, nil means that any letter can be used there
  public typealias Pattern = [Field]
  /// Errors that can occur when a move is inserted
  enum BoardError: Error {
    /// Tried to initialize a board with invalid dimensions
    case dimensions(message: String)
    /// Tried to initialize with invalid start letters
    case startLetters(message: String)
    /// The board does not contain this place
    case invalidPlace
    /// The word does not fit at the intended place
    case patternMismatch
  }
  var sideLength: Int {return fields.rows}
  private var fields: Matrix<Field>
  private var numericFields: Matrix<Int> {
    return fields.map {$0 != nil ? 1 : 0}
  }
  /// Initialize new board with given fields
  public init(fields: Matrix<Field>) throws {
    guard fields.isSquare else {
      throw BoardError.dimensions(message: "Fields matrix must be in square form, equal rows and columns")
    }
    guard fields.isEven else {throw BoardError.dimensions(message: "fields dimensions must be even")}
    self.fields = fields
  }
  /// Initialize a new begriffix board with start letters as 2*2 fields board
  public init(startLetters: Matrix<Letter>, sideLength: Int = 8) throws {
    guard sideLength % 2 == 0 else {throw BoardError.dimensions(message: "sideLength must be even")}
    let startLetters = Matrix<Field>(
      values: startLetters.values, rows: startLetters.rows, columns: startLetters.columns
    )
    var fields = Matrix<Field>(repeating: nil, rows: sideLength, columns: sideLength)
    let center = BegriffixBoard.center(for: sideLength)
    fields[center, center] = startLetters
    try self.init(fields: fields)
  }
  /// Initialize a new begriffix board with start letters as array of four field values
  public init(startLetters: [Letter], sideLength: Int = 8) throws {
    guard startLetters.count == 4 else {throw BoardError.startLetters(message: "Need exactly four start letters")}
    let startLetters = Matrix(values: startLetters, rows: 2, columns: 2)
    try self.init(startLetters: startLetters, sideLength: sideLength)
  }
  /// Initialize a new begriffix game with start letters as 2*2 nested array
  public init?(startLetters: [[Letter]], sideLength: Int = 8) throws {
    guard let startLetters = Matrix<Letter>(values: startLetters) else {return nil}
    try self.init(startLetters: startLetters, sideLength: sideLength)
  }
  /// Initialize a new begriffix game with start letters as string with four characters
  public init(startLetters: String, sideLength: Int = 8) throws {
    let fields = Array(startLetters.unicodeScalars)
    try self.init(startLetters: fields, sideLength: sideLength)
  }
  mutating func insert(_ word: Word, at place: Place) throws {
    guard isValid(place) else {throw BoardError.invalidPlace}
    guard isValid(word, for: pattern(of: place)) else {throw BoardError.patternMismatch}
    let area = place.area
    fields[area] = Matrix(values: word, area: area)
  }
  /// Indicate if the given place is usable
  public func contains(_ place: Place) -> Bool {
    return find(direction: place.direction, count: place.count).contains(place)
  }
  public func isValid(_ word: Word, at place: Place) -> Bool {
    return isValid(place) && isValid(word, for: pattern(of: place))
  }
  public func isValid(_ word: Word, for pattern: Pattern) -> Bool {
    return word.count == pattern.count && word.match(pattern: pattern)
  }
  /// Get the search pattern at a given place
  public func pattern(of place: Place) -> Pattern {
    return fields[place.area].values
  }
  public func isValid(_ place: Place) -> Bool {
    return fields.isValid(area: place.area)
  }
  /// Find every start point where words with given direction and length could be written
  public func find(direction: Direction, count: Int) -> [Place] {
    let kern2 = direction.kernel(2)
    let kern3 = direction.kernel(3)
    let found2 = numericFields.conv2(kern2).extend(kern2)
    let found3 = numericFields.conv2(kern3).extend(kern3).conv2(kern2).dilate(kern2)
    let kernWord = direction.kernel(count)
    let word2 = found2.conv2(kernWord)
    let word3 = found3.conv2(kernWord)
    let word2inv = word2.values.map {$0 >= 2 ? 1 : 0}
    let word3inv = word3.values.map {$0 == 0 ? 1 : 0}
    let allowed = word2inv*word3inv
    let positions = allowed.enumerated()
      .filter {$1 == 1}
      .map { word2.point(of: $0.0)}
    if word2.count == count {
      return positions
        .map {Place(start: $0, direction: direction, count: count)}
    }
    return positions
      .filter { position in
        switch direction {
        case .horizontal:
          if position.column > 0 && fields[position.row, position.column-1] != nil {return false}
          let end = position.column+count
          if end < fields.columns && fields[position.row, end] != nil {return false}
        case .vertical:
          if position.row > 0 && fields[position.row-1, position.column] != nil {return false}
          let end = position.row+count
          if end < fields.rows && fields[end, position.column] != nil {return false}
        }
        return true
      }
      .map {Place(start: $0, direction: direction, count: count)}
  }
  /// Returns the direction which more places exist for
  public func findBalance() -> Direction? {
    let horizontal = self.find(direction: .horizontal, count: self.sideLength).count
    let vertical = self.find(direction: .vertical, count: self.sideLength).count
    if horizontal == vertical {return nil}
    return horizontal > vertical ? .horizontal : .vertical
  }
  /// Return the words crossing the given place after inserting a given word
  public func words(orthogonalTo place: Place, word: Word) -> [Word] {
    let area = place.area
    var fields = self.fields
    fields[area] = Matrix(values: word, area: area)
    let values: [[Letter?]], around: Int
    switch place.direction {
    case .horizontal:
      values = fields.colwise(in: area.columns)
      around = place.start.row
    case .vertical:
      values = fields.rowwise(in: area.rows)
      around = place.start.column
    }
    return values.compactMap {BegriffixBoard.word(in: $0, around: around)}
  }
  /// Extracts a word from a pattern around a given position
  ///
  /// - Parameters:
  ///   - line: A pattern, mostly a board row or column
  ///   - index: The position around which to search for letters.
  /// - Returns: If the element at the given position is part of a word with at least three letters,
  ///   this word is returned, nil otherwise.
  static func word(in line: Pattern, around index: Pattern.Index) -> Word? {
    assert(line.indices.contains(index), "index out of bounds")
    var start = index, end = index
    for next in stride(from: start, through: line.startIndex, by: -1) {
      if line[next] == nil {break}
      start = next
    }
    for next in end..<line.endIndex {
      if line[next] == nil {break}
      end = next
    }
    let range = start...end
    if range.count < 3 {return nil}
    let word = line[range].compactMap {$0}
    return word
  }
  static func center(for sideLength: Int) -> Range<Int> {
    let start = sideLength / 2 - 1
    let end = start + 2
    return start..<end
  }
}

extension BegriffixBoard: LosslessStringConvertible {
  public var description: String {
    let fields = self.fields.values
      .map {Character($0 ?? ".")}
      .chunked(into: self.fields.columns)
      .joined(separator: "\n")
    return String(fields)
  }
  public init?(_ description: String) {
    let rows = description.unicodeScalars.split(separator: "\n").map({Array($0)})
    guard let fields = Matrix<Field>(values: rows) else {return nil}
    self.fields = fields
  }
}
