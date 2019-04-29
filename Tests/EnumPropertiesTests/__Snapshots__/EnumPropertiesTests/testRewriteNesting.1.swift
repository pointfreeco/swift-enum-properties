enum EpisodePermission {
  case loggedIn(subscriberPermission: SubscriberPermission)
  case loggedOut(isEpisodeSubscriberOnly: Bool)

  enum SubscriberPermission {
    case isNotSubscriber(creditPermission: CreditPermission)
    case isSubscriber

    enum CreditPermission {
      case hasNotUsedCredit(isEpisodeSubscriberOnly: Bool)
      case hasUsedCredit

      var hasNotUsedCredit: Bool? {
        get {
          guard case let .hasNotUsedCredit(value) = self else { return nil }
          return value
        }
        set {
          guard case .hasNotUsedCredit = self, let newValue = newValue else { return }
          self = .hasNotUsedCredit(isEpisodeSubscriberOnly: newValue)
        }
      }

      var hasUsedCredit: Void? {
        guard case .hasUsedCredit = self else { return nil }
        return ()
      }
    }

    var isNotSubscriber: CreditPermission? {
      get {
        guard case let .isNotSubscriber(value) = self else { return nil }
        return value
      }
      set {
        guard case .isNotSubscriber = self, let newValue = newValue else { return }
        self = .isNotSubscriber(creditPermission: newValue)
      }
    }

    var isSubscriber: Void? {
      guard case .isSubscriber = self else { return nil }
      return ()
    }
  }

  var loggedIn: SubscriberPermission? {
    get {
      guard case let .loggedIn(value) = self else { return nil }
      return value
    }
    set {
      guard case .loggedIn = self, let newValue = newValue else { return }
      self = .loggedIn(subscriberPermission: newValue)
    }
  }

  var loggedOut: Bool? {
    get {
      guard case let .loggedOut(value) = self else { return nil }
      return value
    }
    set {
      guard case .loggedOut = self, let newValue = newValue else { return }
      self = .loggedOut(isEpisodeSubscriberOnly: newValue)
    }
  }
}
