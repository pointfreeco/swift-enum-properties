enum Traffic {
  case green(Int), yellow(Int), red(Int)

  var green: Int? {
    get {
      guard case let .green(value) = self else { return nil }
      return value
    }
    set {
      guard case .green = self, let newValue = newValue else { return }
      self = .green(newValue)
    }
  }

  var yellow: Int? {
    get {
      guard case let .yellow(value) = self else { return nil }
      return value
    }
    set {
      guard case .yellow = self, let newValue = newValue else { return }
      self = .yellow(newValue)
    }
  }

  var red: Int? {
    get {
      guard case let .red(value) = self else { return nil }
      return value
    }
    set {
      guard case .red = self, let newValue = newValue else { return }
      self = .red(newValue)
    }
  }
}
