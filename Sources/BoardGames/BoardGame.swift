protocol BoardGameOptions {
  var boardSize: Dimensions {get}
  var players: Int {get}
  var turns: Int {get}
}

protocol BoardGame: Sequence {
  associatedtype T: Entity, Hashable
  associatedtype Options: BoardGameOptions
  var board: Matrix<T> {get set}
  var options: Options {get}
  init()
  init(_ options: Options)
}
