import Begriffix

var results = [State]()
let game = Game()
func play() {
  guard let l = game.map({$0.0}).last else {return}
  results.append(l)
}
while results.count < 100 {play()}
results.forEach {print($0.board)}
