import Foundation
import SwiftProtobuf

extension Message {
  init(contentsOf url: URL) throws {
    let data = try Data(contentsOf: url)
    try self.init(serializedData: data)
  }
}
