import Foundation

extension Version {
  /// The git-based versioning constants from Info.plist
  static let current: Version = {
    let dummy = ("0.0.0", "0", "abc")
    let infoPlist = Bundle.main.infoDictionary
    return Version.with {
      $0.short = infoPlist?["CFBundleShortVersionString"] as? String ?? dummy.0
      $0.build = infoPlist?["CFBundleVersion"] as? String ?? dummy.1
      $0.hash = infoPlist?["GITHash"] as? String ?? dummy.2
    }
  }()
  var description: String {
    return "\(short), build \(build), commit hash \(hash)"
  }
}
