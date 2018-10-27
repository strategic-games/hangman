import Foundation

extension SGVersion {
  /// The git-based versioning constants from Info.plist
  static let current: SGVersion = {
    let dummy = ("0.0.0", "0", "abc")
    let infoPlist = Bundle.main.infoDictionary
    return SGVersion.with {
      $0.short = infoPlist?["CFBundleShortVersionString"] as? String ?? dummy.0
      $0.build = infoPlist?["CFBundleVersion"] as? String ?? dummy.1
      $0.hash = infoPlist?["GITHash"] as? String ?? dummy.2
    }
  }()
  var description: String {
    return "\(short), build \(build), commit hash \(hash)"
  }
}
