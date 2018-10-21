import Foundation

struct SimulationStreamer {
  let fileName: String
  let url: URL
  let fileHandle: FileHandle
  init?(fileName: String) {
    self.fileName = fileName
    url = URL(fileURLWithPath: fileName)
    do {
      _ = try url.checkResourceIsReachable()
    } catch {
      FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
    }
    guard let fileHandle = try? FileHandle(forWritingTo: url) else {return nil}
    self.fileHandle = fileHandle
  }
  func append(_ data: Data) {
    fileHandle.seekToEndOfFile()
    fileHandle.write(data)
  }
}

extension Data {
  func append(to url: URL) throws {
    if let fileHandle = try? FileHandle(forWritingTo: url) {
      fileHandle.seekToEndOfFile()
      fileHandle.write(self)
    } else {
      try write(to: url)
    }
  }
}
