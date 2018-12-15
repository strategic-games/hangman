import Foundation

/// A type that can be initialized without any parameters
public protocol TrivialInitializable {
  init()
}

extension Collection {
  /// Returns a new array of transformed elements by mapping concurrently over the collection
  ///
  /// - Parameter transform: The closure that is applied to each element to produce the result elements
  /// - Returns: An array where each element corresponds to one element in the collection
  public func concurrentMap<B: TrivialInitializable>(_ transform: @escaping (Element) -> B) -> [B] {
    let result = ThreadSafe([B](repeating: B(), count: count))
    DispatchQueue.concurrentPerform(iterations: count) { iteration in
      let element = self[index(startIndex, offsetBy: iteration)]
      let transformed = transform(element)
      result.atomically {
        $0[iteration] = transformed
      }
    }
    return result.value
  }
  /// Returns a new array of transformed elements by mapping concurrently over the collection
  ///
  /// - Parameter transform: The closure that is applied to each element to produce the result elements
  /// - Returns: An array where each element corresponds to one element in the collection
  public func concurrentMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
    let result = ThreadSafe([B?](repeating: nil, count: count))
    DispatchQueue.concurrentPerform(iterations: count) { iteration in
      let element = self[index(startIndex, offsetBy: iteration)]
      let transformed = transform(element)
      result.atomically {
        $0[iteration] = transformed
      }
    }
    return result.value.compactMap {$0}
  }
}
