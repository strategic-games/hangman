import Foundation

/// The git-based versioning constants from Info.plist
public struct Version {
  /// The name of the last tag, the count of commits from that tag, and the current commit hash
  public static let (short, build, hash) = getVersion()
  /// A convenience description string
  public static var description: String {
    return "\(Version.short), build \(Version.build), commit hash \(Version.hash)"
  }
  private static func getVersion() -> (String, String, String) {
    let dummy = ("0.0.0", "0", "abc")
    guard let infoPlist = Bundle.main.infoDictionary else {return dummy}
    let short = infoPlist["CFBundleShortVersionString"] as? String ?? dummy.0
    let build = infoPlist["CFBundleVersion"] as? String ?? dummy.1
    let hash = infoPlist["GITHash"] as? String ?? dummy.2
    return (short, build, hash)
  }
}
