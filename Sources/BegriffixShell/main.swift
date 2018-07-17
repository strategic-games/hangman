import Begriffix

var results = [State]()
func play() {
  let game = Game()
  guard let l = game.map({$0.0}).last else {return}
  results.append(l)
}
while results.count < 100 {play()}
results.forEach {print($0.board)}
