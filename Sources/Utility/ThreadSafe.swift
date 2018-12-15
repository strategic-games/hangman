import Foundation

/// A type that can hold any value and provides atomic access
final class ThreadSafe<A> {
  private var _value: A
  private let queue = DispatchQueue(label: "ThreadSafe")
  /// Create a new thread-safe value
  init(_ value: A) {
    self._value = value
  }
  /// Read the value atomically
  var value: A {
    return queue.sync { _value }
  }
  /// Apply a mutating function to the value atomically
  func atomically(_ transform: (inout A) -> Void) {
    queue.sync {
      transform(&self._value)
    }
  }
}
