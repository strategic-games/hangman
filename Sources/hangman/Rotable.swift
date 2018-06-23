protocol Rotable: RangeReplaceableCollection {
  mutating func moveFirst()
  func movedFirst() -> Self
  mutating func moveLast()
  func movedLast() -> Self
  mutating func rotate() -> [Self]
  func rotated() -> [Self]
}

extension String {
  mutating func moveFirst() {
    append(removeFirst())
  }
  mutating func moveFirst(_ n: Int) {
    for _ in 1...n {
      moveFirst()
    }
  }
  func movedFirst() -> String {
    var tmp = self
    tmp.moveFirst()
    return tmp
  }
  func movedFirst(_ n: Int) -> String {
    //if n%count == 0 {return self}
    let i = index(startIndex, offsetBy: n%count)
    return String(suffix(from: i) + prefix(upTo: i))
  }
  mutating func moveLast() {
    insert(removeLast(), at: startIndex)
  }
  mutating func moveLast(_ n: Int) {
    for _ in 1...n {
      moveLast()
    }
  }
  func movedLast() -> String {
    var tmp = self
    tmp.moveLast()
    return tmp
  }
  func movedLast(_ n: Int) -> String {
    var tmp = self
    tmp.moveLast(n)
    return tmp
  }
  func rotated() -> [String] {
    var tmp = self
    var s = [self]
    s.reserveCapacity(self.count)
    while s.count < self.count {
      tmp.moveFirst()
      s.append(tmp)
    }
    return s
  }
}
