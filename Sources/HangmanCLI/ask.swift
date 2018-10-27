enum InputError: Error {
  case conversion(String)
  case validation(String)
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

func agree(_ prompt: String) -> Bool {
  print(prompt)
  repeat {
    guard let str = readLine(strippingNewline: true) else {
      print("Please enter a value")
      continue
    }
    switch str {
    case "yes", "y", "j": return true
    case "no", "n": return false
    default:
      print("Please enter yes/y/j or n/no")
      continue
    }
  } while true
}
