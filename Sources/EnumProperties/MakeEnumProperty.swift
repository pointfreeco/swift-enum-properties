import SwiftSyntax

public func makeEnumProperty(
  forCase enumCase: EnumCaseElementSyntax,
  isPublic: Bool = false,
  leadingSpaces: Int,
  indentBy: Int
  ) -> VariableDeclSyntax {

  let modifiers: ModifierListSyntax?
  let varKeyword: TokenSyntax
  if isPublic {
    modifiers = SyntaxFactory.makeModifierList(
      [
        SyntaxFactory.makeDeclModifier(
          name: SyntaxFactory.makePublicKeyword()
            .withLeadingTrivia([.newlines(2), .spaces(leadingSpaces)])
            .withTrailingTrivia(.spaces(1)),
          detailLeftParen: nil,
          detail: nil,
          detailRightParen: nil
        )
      ]
    )
    varKeyword = SyntaxFactory.makeVarKeyword()
  } else {
    modifiers = nil
    varKeyword = SyntaxFactory.makeVarKeyword()
      .withLeadingTrivia([.newlines(2), .spaces(leadingSpaces)])
  }

  let caseName = enumCase.identifier
  let expressionPattern = SyntaxFactory.makeExpressionPattern(
    expression: SyntaxFactory.makeImplicitMemberExpr(
      dot: SyntaxFactory.makePeriodToken(),
      name: caseName
        .withTrailingTrivia(caseName.trailingTrivia.appending(.spaces(1))),
      declNameArguments: nil
    )
  )

  func makeGetter(pattern: PatternSyntax, value: ExprSyntax, keywordPresent: Bool) -> AccessorDeclSyntax {
    let accessorKind: TokenSyntax = keywordPresent
      ? SyntaxFactory.makeToken(.contextualKeyword("get"), presence: .present)
        .withLeadingTrivia([.newlines(1), .spaces(leadingSpaces + indentBy)])
        .withTrailingTrivia(.spaces(1))
      : SyntaxFactory.makeToken(.contextualKeyword("get"), presence: .missing)
    let indentation = leadingSpaces + indentBy*(keywordPresent ? 2 : 1)
    return SyntaxFactory.makeAccessorDecl(
      attributes: nil,
      modifier: nil,
      accessorKind: accessorKind,
      parameter: nil,
      body: SyntaxFactory.makeCodeBlock(
        leftBrace: keywordPresent
          ? SyntaxFactory.makeLeftBraceToken()
          : SyntaxFactory.makeToken(.leftBrace, presence: .missing),
        statements: SyntaxFactory.makeCodeBlockItemList(
          [
            SyntaxFactory.makeCodeBlockItem(
              item: SyntaxFactory.makeGuardStmt(
                guardKeyword: SyntaxFactory.makeGuardKeyword()
                  .withLeadingTrivia([.newlines(1), .spaces(indentation)])
                  .withTrailingTrivia(.spaces(1)),
                conditions: SyntaxFactory.makeConditionElementList(
                  [
                    SyntaxFactory.makeConditionElement(
                      condition: SyntaxFactory.makeMatchingPatternCondition(
                        caseKeyword: SyntaxFactory.makeCaseKeyword()
                          .withTrailingTrivia(.spaces(1)),
                        pattern: pattern,
                        typeAnnotation: nil,
                        initializer: SyntaxFactory.makeInitializerClause(
                          equal: SyntaxFactory.makeEqualToken()
                            .withTrailingTrivia(.spaces(1)),
                          value: SyntaxFactory.makeIdentifierExpr(
                            identifier: SyntaxFactory.makeIdentifier("self")
                              .withTrailingTrivia(.spaces(1)),
                            declNameArguments: nil
                          )
                        )
                      ),
                      trailingComma: nil
                    )
                  ]
                ),
                elseKeyword: SyntaxFactory.makeElseKeyword()
                  .withTrailingTrivia(.spaces(1)),
                body: SyntaxFactory.makeCodeBlock(
                  leftBrace: SyntaxFactory.makeLeftBraceToken()
                    .withTrailingTrivia(.spaces(1)),
                  statements: SyntaxFactory.makeCodeBlockItemList(
                    [
                      SyntaxFactory.makeCodeBlockItem(
                        item: SyntaxFactory.makeReturnStmt(
                          returnKeyword: SyntaxFactory.makeReturnKeyword()
                            .withTrailingTrivia(.spaces(1)),
                          expression: SyntaxFactory.makeNilLiteralExpr(
                            nilKeyword: SyntaxFactory.makeNilKeyword()
                              .withTrailingTrivia(.spaces(1))
                          )
                        ),
                        semicolon: nil,
                        errorTokens: nil
                      )
                    ]
                  ),
                  rightBrace: SyntaxFactory.makeRightBraceToken()
                )
              ),
              semicolon: nil,
              errorTokens: nil
            ),
            SyntaxFactory.makeCodeBlockItem(
              item: SyntaxFactory.makeReturnStmt(
                returnKeyword: SyntaxFactory.makeReturnKeyword()
                  .withLeadingTrivia([.newlines(1), .spaces(indentation)])
                  .withTrailingTrivia(.spaces(1)),
                expression: value
              ),
              semicolon: nil,
              errorTokens: nil
            )
          ]
        ),
        rightBrace: keywordPresent
          ? SyntaxFactory.makeRightBraceToken()
            .withLeadingTrivia([.newlines(1), .spaces(leadingSpaces + indentBy)])
          : SyntaxFactory.makeToken(.leftBrace, presence: .missing)
      )
    )
  }

  let type: TypeSyntax
  let pattern: PatternSyntax
  let value: ExprSyntax
  let getter: AccessorDeclSyntax
  let setter: AccessorDeclSyntax?
  if let associatedValue = enumCase.associatedValue {
    if associatedValue.parameterList.count == 1 {
      type = associatedValue.parameterList[0].type!
    } else {
      type = SyntaxFactory.makeTupleType(
        leftParen: SyntaxFactory.makeLeftParenToken(),
        elements: SyntaxFactory.makeTupleTypeElementList(
          associatedValue.parameterList.enumerated().map {
            SyntaxFactory.makeTupleTypeElement(
              name: $1.firstName,
              colon: $1.colon,
              type: $1.type!,
              trailingComma: $0 == associatedValue.parameterList.count - 1
                ? nil
                : SyntaxFactory.makeCommaToken().withTrailingTrivia(.spaces(1))
            )
          }
        ),
        rightParen: SyntaxFactory.makeRightParenToken()
      )
    }
    value = SyntaxFactory.makeVariableExpr("value")
    pattern = SyntaxFactory.makeValueBindingPattern(
      letOrVarKeyword: SyntaxFactory.makeLetKeyword()
        .withTrailingTrivia(.spaces(1)),
      valuePattern: SyntaxFactory.makeExpressionPattern(
        expression: SyntaxFactory.makeFunctionCallExpr(
          calledExpression: SyntaxFactory.makeImplicitMemberExpr(
            dot: SyntaxFactory.makePeriodToken(),
            name: caseName,
            declNameArguments: nil
          ),
          leftParen: SyntaxFactory.makeLeftParenToken(),
          argumentList: SyntaxFactory.makeFunctionCallArgumentList(
            [
              SyntaxFactory.makeFunctionCallArgument(
                label: nil,
                colon: nil,
                expression: value,
                trailingComma: nil
              )
            ]
          ),
          rightParen: SyntaxFactory.makeRightParenToken()
            .withTrailingTrivia(.spaces(1)),
          trailingClosure: nil
        )
      )
    )
    getter = makeGetter(pattern: pattern, value: value, keywordPresent: true)
    setter = SyntaxFactory.makeAccessorDecl(
      attributes: nil,
      modifier: nil,
      accessorKind: SyntaxFactory.makeToken(.contextualKeyword("set"), presence: .present)
        .withLeadingTrivia([.newlines(1), .spaces(leadingSpaces + indentBy)])
        .withTrailingTrivia(.spaces(1)),
      parameter: nil,
      body: SyntaxFactory.makeCodeBlock(
        leftBrace: SyntaxFactory.makeLeftBraceToken(),
        statements: SyntaxFactory.makeCodeBlockItemList(
          [
            SyntaxFactory.makeCodeBlockItem(
              item: SyntaxFactory.makeGuardStmt(
                guardKeyword: SyntaxFactory.makeGuardKeyword()
                  .withLeadingTrivia([.newlines(1), .spaces(leadingSpaces + indentBy*2)])
                  .withTrailingTrivia(.spaces(1)),
                conditions: SyntaxFactory.makeConditionElementList(
                  [
                    SyntaxFactory.makeConditionElement(
                      condition: SyntaxFactory.makeMatchingPatternCondition(
                        caseKeyword: SyntaxFactory.makeCaseKeyword()
                          .withTrailingTrivia(.spaces(1)),
                        pattern: expressionPattern,
                        typeAnnotation: nil,
                        initializer: SyntaxFactory.makeInitializerClause(
                          equal: SyntaxFactory.makeEqualToken()
                            .withTrailingTrivia(.spaces(1)),
                          value: SyntaxFactory.makeIdentifierExpr(
                            identifier: SyntaxFactory.makeIdentifier("self"),
                            declNameArguments: nil
                          )
                        )
                      ),
                      trailingComma: SyntaxFactory.makeCommaToken()
                        .withTrailingTrivia(.spaces(1))
                    ),
                    SyntaxFactory.makeConditionElement(
                      condition: SyntaxFactory.makeOptionalBindingCondition(
                        letOrVarKeyword: SyntaxFactory.makeLetKeyword()
                          .withTrailingTrivia(.spaces(1)),
                        pattern: SyntaxFactory.makeIdentifierPattern(
                          identifier: SyntaxFactory.makeIdentifier("newValue")
                            .withTrailingTrivia(.spaces(1))
                        ),
                        typeAnnotation: nil,
                        initializer: SyntaxFactory.makeInitializerClause(
                          equal: SyntaxFactory.makeEqualToken()
                            .withTrailingTrivia(.spaces(1)),
                          value: SyntaxFactory.makeIdentifierExpr(
                            identifier: SyntaxFactory.makeIdentifier("newValue")
                              .withTrailingTrivia(.spaces(1)),
                            declNameArguments: nil
                          )
                        )
                      ),
                      trailingComma: nil
                    )
                  ]
                ),
                elseKeyword: SyntaxFactory.makeElseKeyword()
                  .withTrailingTrivia(.spaces(1)),
                body: SyntaxFactory.makeCodeBlock(
                  leftBrace: SyntaxFactory.makeLeftBraceToken()
                    .withTrailingTrivia(.spaces(1)),
                  statements: SyntaxFactory.makeCodeBlockItemList(
                    [
                      SyntaxFactory.makeCodeBlockItem(
                        item: SyntaxFactory.makeReturnStmt(
                          returnKeyword: SyntaxFactory.makeReturnKeyword()
                            .withTrailingTrivia(.spaces(1)),
                          expression: nil
                        ),
                        semicolon: nil,
                        errorTokens: nil
                      )
                    ]
                  ),
                  rightBrace: SyntaxFactory.makeRightBraceToken()
                )
              ),
              semicolon: nil,
              errorTokens: nil
            ),
            SyntaxFactory.makeCodeBlockItem(
              item: SyntaxFactory.makeSequenceExpr(
                elements: SyntaxFactory.makeExprList(
                  [
                    SyntaxFactory.makeIdentifierExpr(
                      identifier: SyntaxFactory.makeIdentifier("self")
                        .withLeadingTrivia([.newlines(1), .spaces(leadingSpaces + indentBy*2)])
                        .withTrailingTrivia(.spaces(1)),
                      declNameArguments: nil
                    ),
                    SyntaxFactory.makeAssignmentExpr(
                      assignToken: SyntaxFactory.makeEqualToken()
                        .withTrailingTrivia(.spaces(1))
                    ),
                    SyntaxFactory.makeFunctionCallExpr(
                      calledExpression: SyntaxFactory.makeImplicitMemberExpr(
                        dot: SyntaxFactory.makePeriodToken(),
                        name: caseName,
                        declNameArguments: nil
                      ),
                      leftParen: SyntaxFactory.makeLeftParenToken(),
                      argumentList: SyntaxFactory.makeFunctionCallArgumentList(
                        associatedValue.parameterList.enumerated().map {
                          SyntaxFactory.makeFunctionCallArgument(
                            label: $1.firstName,
                            colon: $1.colon,
                            expression: associatedValue.parameterList.count == 1
                              ? SyntaxFactory.makeIdentifierExpr(
                                identifier: SyntaxFactory.makeIdentifier("newValue"),
                                declNameArguments: nil
                                )
                              : SyntaxFactory.makeMemberAccessExpr(
                                base: SyntaxFactory.makeIdentifierExpr(
                                  identifier: SyntaxFactory.makeIdentifier("newValue"),
                                  declNameArguments: nil
                                ),
                                dot: SyntaxFactory.makePeriodToken(),
                                name: SyntaxFactory.makeIdentifier(String($0)),
                                declNameArguments: nil
                              ),
                            trailingComma: $0 == associatedValue.parameterList.count - 1
                              ? nil
                              : SyntaxFactory.makeCommaToken()
                                .withTrailingTrivia(.spaces(1))
                          )
                        }
                      ),
                      rightParen: SyntaxFactory.makeRightParenToken(),
                      trailingClosure: nil
                    )
                  ]
                )
              ),
              semicolon: nil,
              errorTokens: nil
            )
          ]
        ),
        rightBrace: SyntaxFactory.makeRightBraceToken()
          .withLeadingTrivia([.newlines(1), .spaces(leadingSpaces + indentBy)])
      )
    )
  } else {
    type = SyntaxFactory.makeTypeIdentifier("Void")
    value = SyntaxFactory.makeTupleExpr(
      leftParen: SyntaxFactory.makeLeftParenToken(),
      elementList: SyntaxFactory.makeTupleElementList([]),
      rightParen: SyntaxFactory.makeRightParenToken()
    )
    pattern = expressionPattern
    getter = makeGetter(pattern: pattern, value: value, keywordPresent: false)
    setter = nil
  }

  let accessors = [getter, setter].compactMap { $0 }

  return SyntaxFactory.makeVariableDecl(
    attributes: nil,
    modifiers: modifiers,
    letOrVarKeyword: varKeyword
      .withTrailingTrivia(.spaces(1)),
    bindings: SyntaxFactory.makePatternBindingList(
      [
        SyntaxFactory.makePatternBinding(
          pattern: SyntaxFactory.makeIdentifierPattern(
            identifier: caseName
          ),
          typeAnnotation: SyntaxFactory.makeTypeAnnotation(
            colon: SyntaxFactory.makeColonToken()
              .withTrailingTrivia(.spaces(1)),
            type: SyntaxFactory.makeOptionalType(
              wrappedType: type,
              questionMark: SyntaxFactory.makePostfixQuestionMarkToken()
                .withTrailingTrivia(.spaces(1))
            )
          ),
          initializer: nil,
          accessor: SyntaxFactory.makeAccessorBlock(
            leftBrace: SyntaxFactory.makeLeftBraceToken(),
            accessors: SyntaxFactory.makeAccessorList(accessors),
            rightBrace: SyntaxFactory.makeRightBraceToken()
              .withLeadingTrivia([.newlines(1), .spaces(leadingSpaces)])
          ),
          trailingComma: nil
        )
      ]
    )
  )
}
