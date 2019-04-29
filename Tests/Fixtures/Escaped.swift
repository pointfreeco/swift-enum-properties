enum EmailLayoutTemplate {
  case blog
  case `default`(theme: String)

  var blog: Void? {
    guard case .blog = self else { return nil }
    return ()
  }

  var `default`: String? {
    get {
      guard case let .`default`(value) = self else { return nil }
      return value
    }
    set {
      guard case .`default` = self, let newValue = newValue else { return }
      self = .`default`(theme: newValue)
    }
  }
}
