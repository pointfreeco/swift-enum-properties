import SwiftSyntax

public class EnumPropertyRewriter: SyntaxRewriter {
  var indents: [Int] = []
  var stack: [(enumCases: [EnumCaseElementSyntax], variables: Set<String>)] = []

  override public func visitPre(_ node: Syntax) {
    let indent = abs(indents.last ?? 0 - node.leadingTriviaLength.columnsAtLastLine)
    guard indent != 0 else { return }
    self.indents.append(indent)
  }

  override public func visit(_ node: SourceFileSyntax) -> Syntax {
    self.indents.removeAll()
    return super.visit(node) as! SourceFileSyntax
  }

  override public func visit(_ node: EnumDeclSyntax) -> DeclSyntax {
    self.stack.append(([], []))
    
    defer {
      self.stack.removeLast()
    }

    let node = super.visit(node) as! EnumDeclSyntax

    let allEnumCases = self.stack.last!.enumCases
    let enumCases = allEnumCases
      .filter { !self.stack.last!.variables.contains($0.identifier.withoutTrivia().description) }

    guard
      !enumCases.isEmpty,
      allEnumCases.contains(where: { $0.associatedValue != nil })
      else { return node }

    let isPublic = node.modifiers?
      .contains(where: { $0.name.withoutTrivia().description == "public" })
      ?? false

    let indentation = Int(Double(self.indents.reduce(0, +)) / Double(self.indents.count))

    return enumCases.reduce(node) { node, enumCase in
      node.withMembers(
        node.members.addMemberDeclListItem(
          SyntaxFactory.makeMemberDeclListItem(
            decl: makeEnumProperty(
              forCase: enumCase,
              isPublic: isPublic,
              leadingSpaces: Int(node.leadingTriviaLength.columnsAtLastLine + indentation),
              indentBy: Int(indentation)
            ),
            semicolon: nil
          )
        )
      )
    }
  }

  override public func visit(_ node: EnumCaseElementSyntax) -> Syntax {
    self.stack[self.stack.count - 1].enumCases.append(node)
    return node
  }

  override public func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
    guard !self.stack.isEmpty else { return node }
    self.stack[self.stack.count - 1].variables.formUnion(
      node.bindings
        .compactMap { ($0.pattern as? IdentifierPatternSyntax)?.identifier.withoutTrivia().description }
    )
    return node
  }
}
