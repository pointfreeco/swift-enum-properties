public struct Episode {
  public struct Id {}
}

public enum Route {
  case home
  case episode(id: Episode.Id, ref: String)
  var home: Void? {
    get {
      guard case .home = self else { return nil }
      return ()
    }
  }

  public var episode: (id: Episode.Id, ref: String)? {
    get {
      guard case let .episode(value) = self else { return nil }
      return value
    }
    set {
      guard case .episode = self, let newValue = newValue else { return }
      self = .episode(id: newValue.0, ref: newValue.1)
    }
  }
}
