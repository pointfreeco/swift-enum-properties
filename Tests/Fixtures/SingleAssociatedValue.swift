enum MyError: Error {
  case myError(message: String)

  var myError: String? {
    get {
      guard case let .myError(value) = self else { return nil }
      return value
    }
    set {
      guard case .myError = self, let newValue = newValue else { return }
      self = .myError(message: newValue)
    }
  }
}
