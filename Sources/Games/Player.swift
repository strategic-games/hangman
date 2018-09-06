public protocol Player {}
/// A type that is able to play Begriffix
public protocol BegriffixPlayer: Player {
  /// Provides the next move for a Begriffix game
  func move(_ game: Begriffix) -> Begriffix.Move?
}
