enum InputError: Error {
  case Conversion(String)
  case Validation(String)
}

typealias Validator<T> = (T) -> (Bool, String)

func ask<T: LosslessStringConvertible>(_ prompt: String, validator: Validator<T>? = nil) -> T {
  repeat {
    print(prompt+":")
    guard let str = readLine(strippingNewline: true) else {
      print("Please enter a value")
      continue
    }
    guard let value = T(str) else {
      print("Invalid value, please try again")
      continue
    }
    if let validator = validator {
      let (isValid, message) = validator(value)
      guard isValid else {
        print(message)
        continue
      }
      print(message)
    }
    return value
  } while true
}
