public protocol Player {
  func deal(with state: State) -> Move?
}
