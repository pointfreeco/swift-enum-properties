import EnumProperties
import SnapshotTesting
import SwiftSyntax
import XCTest

final class EnumPropertiesTests: XCTestCase {
  func testExample() {
    let enumCase0 = EnumCaseElementSyntax {
      $0.useIdentifier(SyntaxFactory.makeIdentifier("cancelled"))
    }
    let enumProperty0 = makeEnumProperty(forCase: enumCase0, leadingSpaces: 0, indentBy: 4)
    _assertInlineSnapshot(matching: enumProperty0, as: .syntax, with: """
    var cancelled: Void? {
        guard case .cancelled = self else { return nil }
        return ()
    }
    """)

    let enumCase1 = SyntaxFactory.makeEnumCaseElement(
      identifier: SyntaxFactory.makeIdentifier("valid"),
      associatedValue: SyntaxFactory.makeParameterClause(
        leftParen: SyntaxFactory.makeLeftParenToken(),
        parameterList: SyntaxFactory.makeFunctionParameterList(
          [
            SyntaxFactory.makeFunctionParameter(
              attributes: nil,
              firstName: nil,
              secondName: nil,
              colon: nil,
              type: SyntaxFactory.makeTypeIdentifier("Valid"),
              ellipsis: nil,
              defaultArgument: nil,
              trailingComma: nil
            )
          ]
        ),
        rightParen: SyntaxFactory.makeRightParenToken()
      ),
      rawValue: nil,
      trailingComma: nil
    )
    let enumProperty1 = makeEnumProperty(forCase: enumCase1, leadingSpaces: 0, indentBy: 4)
    _assertInlineSnapshot(matching: enumProperty1, as: .syntax, with: """
    var valid: Valid? {
        get {
            guard case let .valid(value) = self else { return nil }
            return value
        }
        set {
            guard case .valid = self, let newValue = newValue else { return }
            self = .valid(newValue)
        }
    }
    """)

    let enumCase2 = SyntaxFactory.makeEnumCaseElement(
      identifier: SyntaxFactory.makeIdentifier("element"),
      associatedValue: SyntaxFactory.makeParameterClause(
        leftParen: SyntaxFactory.makeLeftParenToken(),
        parameterList: SyntaxFactory.makeFunctionParameterList(
          [
            SyntaxFactory.makeFunctionParameter(
              attributes: nil,
              firstName: SyntaxFactory.makeIdentifier("tag"),
              secondName: nil,
              colon: SyntaxFactory.makeColonToken().withTrailingTrivia(.spaces(1)),
              type: SyntaxFactory.makeTypeIdentifier("String"),
              ellipsis: nil,
              defaultArgument: nil,
              trailingComma: SyntaxFactory.makeCommaToken().withTrailingTrivia(.spaces(1))
            ),
            SyntaxFactory.makeFunctionParameter(
              attributes: nil,
              firstName: SyntaxFactory.makeIdentifier("attributes"),
              secondName: nil,
              colon: SyntaxFactory.makeColonToken().withTrailingTrivia(.spaces(1)),
              type: SyntaxFactory.makeTypeIdentifier("[String: String]"),
              ellipsis: nil,
              defaultArgument: nil,
              trailingComma: SyntaxFactory.makeCommaToken().withTrailingTrivia(.spaces(1))
            ),
            SyntaxFactory.makeFunctionParameter(
              attributes: nil,
              firstName: SyntaxFactory.makeIdentifier("children"),
              secondName: nil,
              colon: SyntaxFactory.makeColonToken().withTrailingTrivia(.spaces(1)),
              type: SyntaxFactory.makeTypeIdentifier("[Node]"),
              ellipsis: nil,
              defaultArgument: nil,
              trailingComma: nil
            )
          ]
        ),
        rightParen: SyntaxFactory.makeRightParenToken()
      ),
      rawValue: nil,
      trailingComma: nil
    )
    let enumProperty2 = makeEnumProperty(forCase: enumCase2, leadingSpaces: 0, indentBy: 4)
    _assertInlineSnapshot(matching: enumProperty2, as: .syntax, with: """
    var element: (tag: String, attributes: [String: String], children: [Node])? {
        get {
            guard case let .element(value) = self else { return nil }
            return value
        }
        set {
            guard case .element = self, let newValue = newValue else { return }
            self = .element(tag: newValue.0, attributes: newValue.1, children: newValue.2)
        }
    }
    """)
  }

  func testRewriteExisting() throws {
    assertSnapshot(matching: fixture(named: "Existing"), as: .syntax)
    _assertInlineSnapshot(matching: fixture(named: "Existing"), as: .syntax, with: """
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
    """)
  }

  func testRewriteNesting() throws {
    assertSnapshot(matching: fixture(named: "Nesting"), as: .syntax)
    _assertInlineSnapshot(matching: fixture(named: "Nesting"), as: .syntax, with: """
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
    """)
  }

  func testRewriteEscaped() throws {
    assertSnapshot(matching: fixture(named: "Escaped"), as: .syntax)
    _assertInlineSnapshot(matching: fixture(named: "Escaped"), as: .syntax, with: """
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
    """)
  }

  func testSingleDecl() throws {
    assertSnapshot(matching: fixture(named: "SingleDecl"), as: .syntax)
    _assertInlineSnapshot(matching: fixture(named: "SingleDecl"), as: .syntax, with: """
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
    """)
  }

  func testNoAssociatedValues() {
    assertSnapshot(matching: fixture(named: "NoAssociatedValues"), as: .syntax)
    _assertInlineSnapshot(matching: fixture(named: "NoAssociatedValues"), as: .syntax, with: """
    enum CodingKeys: String, CodingKey {
      case id
      case name
      case email
    }
    """)
  }

  func testSingleAssociatedValue() {
    assertSnapshot(matching: fixture(named: "SingleAssociatedValue"), as: .syntax)
    _assertInlineSnapshot(matching: fixture(named: "SingleAssociatedValue"), as: .syntax, with: """
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
    """)
  }
}

private func fixture(named name: String) -> URL {
  return URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("Fixtures")
    .appendingPathComponent("\(name).swift")
}

extension Snapshotting where Value == Syntax, Format == String {
  static let syntax: Snapshotting = {
    var snapshotting: Snapshotting = SimplySnapshotting.lines.pullback { $0.description }
    snapshotting.pathExtension = "swift"
    return snapshotting
  }()
}

extension Snapshotting where Value: Syntax, Format == String {
  static var syntax: Snapshotting {
    return Snapshotting<Syntax, String>.syntax.pullback { $0 as Syntax }
  }
}

extension Snapshotting where Value == URL, Format == String {
  static let syntax: Snapshotting = Snapshotting<Syntax, String>.syntax.pullback { url in
    let source = try! SyntaxParser.parse(url)
    let rewriter = EnumPropertyRewriter(includeAll: false)
    return rewriter.visit(source)
  }
}
