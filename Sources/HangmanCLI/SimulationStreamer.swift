import Foundation

struct SimulationStreamer {
  let url: URL
  let fileHandle: FileHandle
  init?(url: URL) {
    self.url = url
    do {
      _ = try url.checkResourceIsReachable()
    } catch {
      FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
    }
    guard let fileHandle = try? FileHandle(forWritingTo: url) else {return nil}
    self.fileHandle = fileHandle
  }
  init?(path: String) {
    self.init(url: URL(fileURLWithPath: path))
  }
  init?(fileName: String, dir: String? = nil) {
    let dirUrl = URL(fileURLWithPath: dir ?? ".", isDirectory: true)
    do {
      try FileManager.default.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: nil)
      self.init(url: dirUrl.appendingPathComponent(fileName))
    } catch {
      return nil
    }
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
