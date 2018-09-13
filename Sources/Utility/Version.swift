import Foundation

public struct Version {
  public static let (short, build, hash) = getVersion()
  public static var description: String {
    return "\(Version.short), build \(Version.build), commit hash \(Version.hash)"
  }
  static func getVersion() -> (String, String, String) {
    let dummy = ("0.0.0", "0", "abc")
    guard let infoPlist = Bundle(identifier: "Utility")?.infoDictionary else {return dummy}
    guard let short = infoPlist["CFBundleShortVersionString"] as? String else {return dummy}
    guard let build = infoPlist["CFBundleVersion"] as? String else {return dummy}
    guard let hash = infoPlist["GITHash"] as? String else {return dummy}
    return (short, build, hash)
  }
}
