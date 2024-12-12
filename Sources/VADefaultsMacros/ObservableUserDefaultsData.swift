//
//  ObservableUserDefaultsData.swift
//  VADefaults
//
//  Created by VAndrJ on 12/11/24.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObservableUserDefaultsData {
    static let moduleName = "Observation"
    static let conformanceName = "Observable"
    static var qualifiedConformanceName: String { "\(moduleName).\(conformanceName)" }
    static let registrarTypeName = "ObservationRegistrar"
    static var qualifiedRegistrarTypeName: String { "\(moduleName).\(registrarTypeName)" }
    static let trackedMacroName = "ObservationTracked"
    static let ignoredMacroName = "ObservationIgnored"
    static let registrarVariableName = "_$observationRegistrar"

    static func registrarVariable(_ observableType: TokenSyntax) -> DeclSyntax {
        """
        @\(raw: ignoredMacroName) private let \(raw: registrarVariableName) = \(raw: qualifiedRegistrarTypeName)()
        """
    }

    static func accessFunction(_ observableType: TokenSyntax) -> DeclSyntax {
        """
        internal nonisolated func access<Member>(
        keyPath: KeyPath<\(observableType), Member>
        ) {
        \(raw: registrarVariableName).access(self, keyPath: keyPath)
        }
        """
    }

    static func withMutationFunction(_ observableType: TokenSyntax) -> DeclSyntax {
        """
        internal nonisolated func withMutation<Member, MutationResult>(
        keyPath: KeyPath<\(observableType), Member>,
        _ mutation: () throws -> MutationResult
        ) rethrows -> MutationResult {
        try \(raw: registrarVariableName).withMutation(of: self, keyPath: keyPath, mutation)
        }
        """
    }
}

extension VariableDeclSyntax {
    var isValidForObservation: Bool { !isComputed && isInstance && !isImmutable && identifier != nil }
}

extension ObservableUserDefaultsData: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax,
        Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        conformingTo protocols: [TypeSyntax],
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let identified = declaration.as(ClassDeclSyntax.self) else {
            throw UserDefaultsValueError.classNeeded
        }

        let observableType = identified.name.trimmed
        let labeledExprListSyntax = node.arguments?.as(LabeledExprListSyntax.self)
        let defaults = labeledExprListSyntax?.defaultsParam ?? .standardDefaults
        let modifier = identified.modifiers.initModifier
        var declarations: [DeclSyntax] = [
            """
            private let \(raw: UserDefaultsData.variableName): \(raw: UserDefaultsData.defaults)

            \(raw: modifier)init(\(raw: UserDefaultsData.variableName): \(raw: UserDefaultsData.defaults) = \(raw: defaults)) {
                self.\(raw: UserDefaultsData.variableName) = \(raw: UserDefaultsData.variableName)
            }
            """
        ]
        declaration.addIfNeeded(
            ObservableUserDefaultsData.registrarVariable(observableType), to: &declarations)
        declaration.addIfNeeded(
            ObservableUserDefaultsData.accessFunction(observableType), to: &declarations)
        declaration.addIfNeeded(
            ObservableUserDefaultsData.withMutationFunction(observableType), to: &declarations)

        return declarations
    }
}

extension ObservableUserDefaultsData: MemberAttributeMacro {

    public static func expansion<
        Declaration: DeclGroupSyntax,
        MemberDeclaration: DeclSyntaxProtocol,
        Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        attachedTo declaration: Declaration,
        providingAttributesFor member: MemberDeclaration,
        in context: Context
    ) throws -> [AttributeSyntax] {
        guard let variableDeclSyntax = member.as(VariableDeclSyntax.self),         variableDeclSyntax.isValidForObservation,
              variableDeclSyntax.identifier != nil
        else {
            return []
        }

        // dont apply to ignored properties or properties that are already flagged as tracked
        if variableDeclSyntax.hasMacroApplication(ObservableUserDefaultsData.ignoredMacroName) ||
            variableDeclSyntax.hasMacroApplication(ObservableUserDefaultsData.trackedMacroName) {
            return []
        }
        guard !variableDeclSyntax.attributes.isDefaultsValueMacro else {
            return []
        }
        guard variableDeclSyntax.bindings.count == 1,
            !variableDeclSyntax.bindings.contains(where: {
                $0.initializer != nil || $0.accessorBlock != nil
            })
        else {
            return [AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier(ObservableUserDefaultsData.trackedMacroName)))]
        }

        return [
            "@\(raw: String(describing: DefaultsValue.self))",
        ]
    }
}

extension ObservableUserDefaultsData: ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard declaration.is(ClassDeclSyntax.self) else {
            throw UserDefaultsValueError.classNeeded
        }

        let decl: DeclSyntax = """
            extension \(raw: type.trimmedDescription): \(raw: qualifiedConformanceName) {}
            """
        let ext = decl.cast(ExtensionDeclSyntax.self)

        if var availability = declaration.attributes.availability {
            if availability.trailingTrivia != .newline {
                availability = availability.with(\.trailingTrivia, .newline)
            }
            return [ext.with(\.attributes, availability)]
        } else {
            return [ext]
        }
    }
}

extension VariableDeclSyntax {
    var identifierPattern: IdentifierPatternSyntax? { bindings.first?.pattern.as(IdentifierPatternSyntax.self) }
    var isInstance: Bool {
        for modifier in modifiers {
            for token in modifier.tokens(viewMode: .all) {
                if token.tokenKind == .keyword(.static) || token.tokenKind == .keyword(.class) {
                    return false
                }
            }
        }

        return true
    }
    var identifier: TokenSyntax? { identifierPattern?.identifier }
    var type: TypeSyntax? { bindings.first?.typeAnnotation?.type }

    func accessorsMatching(_ predicate: (TokenKind) -> Bool) -> [AccessorDeclSyntax] {
        let accessors: [AccessorDeclListSyntax.Element] = bindings.compactMap { patternBinding in
            switch patternBinding.accessorBlock?.accessors {
            case .accessors(let accessors):
                return accessors
            default:
                return nil
            }
        }.flatMap { $0 }

        return accessors.compactMap { accessor in
            if predicate(accessor.accessorSpecifier.tokenKind) {
                return accessor
            } else {
                return nil
            }
        }
    }

    var isComputed: Bool {
        if accessorsMatching({ $0 == .keyword(.get) }).count > 0 {
            return true
        } else {
            return bindings.contains { binding in
                if case .getter = binding.accessorBlock?.accessors {
                    return true
                } else {
                    return false
                }
            }
        }
    }

    var isImmutable: Bool { bindingSpecifier.tokenKind == .keyword(.let) }

    func isEquivalent(to other: VariableDeclSyntax) -> Bool {
        if isInstance != other.isInstance {
            return false
        }

        return identifier?.text == other.identifier?.text
    }

    func hasMacroApplication(_ name: String) -> Bool {
        for attribute in attributes {
            switch attribute {
            case .attribute(let attr):
                if attr.attributeName.tokens(viewMode: .all).map({ $0.tokenKind }) == [
                    .identifier(name)
                ] {
                    return true
                }
            default:
                break
            }
        }

        return false
    }
}

extension TypeSyntax {
    var identifier: String? {
        for token in tokens(viewMode: .all) {
            switch token.tokenKind {
            case .identifier(let identifier):
                return identifier
            default:
                break
            }
        }

        return nil
    }

    func genericSubstitution(_ parameters: GenericParameterListSyntax?) -> String? {
        var genericParameters = [String: TypeSyntax?]()
        if let parameters {
            for parameter in parameters {
                genericParameters[parameter.name.text] = parameter.inheritedType
            }
        }
        var iterator = self.asProtocol(TypeSyntaxProtocol.self).tokens(viewMode: .sourceAccurate)
            .makeIterator()
        guard let base = iterator.next() else {
            return nil
        }

        if let genericBase = genericParameters[base.text] {
            if let text = genericBase?.identifier {
                return "some " + text
            } else {
                return nil
            }
        }
        var substituted = base.text

        while let token = iterator.next() {
            switch token.tokenKind {
            case .leftAngle:
                substituted += "<"
            case .rightAngle:
                substituted += ">"
            case .comma:
                substituted += ","
            case .identifier(let identifier):
                let type: TypeSyntax = "\(raw: identifier)"
                guard let substituedType = type.genericSubstitution(parameters) else {
                    return nil
                }
                substituted += substituedType
                break
            default:
                // ignore?
                break
            }
        }

        return substituted
    }
}

extension FunctionDeclSyntax {
    var isInstance: Bool {
        for modifier in modifiers {
            for token in modifier.tokens(viewMode: .all) {
                if token.tokenKind == .keyword(.static) || token.tokenKind == .keyword(.class) {
                    return false
                }
            }
        }

        return true
    }

    struct SignatureStandin: Equatable {
        var isInstance: Bool
        var identifier: String
        var parameters: [String]
        var returnType: String
    }

    var signatureStandin: SignatureStandin {
        var parameters = [String]()
        for parameter in signature.parameterClause.parameters {
            parameters.append(
                parameter.firstName.text + ":"
                    + (parameter.type.genericSubstitution(genericParameterClause?.parameters) ?? "")
            )
        }
        let returnType =
            signature.returnClause?.type.genericSubstitution(genericParameterClause?.parameters)
            ?? "Void"
        return SignatureStandin(
            isInstance: isInstance,
            identifier: name.text,
            parameters: parameters,
            returnType: returnType
        )
    }

    func isEquivalent(to other: FunctionDeclSyntax) -> Bool {
        signatureStandin == other.signatureStandin
    }
}

extension DeclGroupSyntax {

    func hasMemberFunction(equvalentTo other: FunctionDeclSyntax) -> Bool {
        for member in memberBlock.members {
            if let function = member.decl.as(FunctionDeclSyntax.self) {
                if function.isEquivalent(to: other) {
                    return true
                }
            }
        }
        return false
    }

    func hasMemberProperty(equivalentTo other: VariableDeclSyntax) -> Bool {
        for member in memberBlock.members {
            if let variable = member.decl.as(VariableDeclSyntax.self) {
                if variable.isEquivalent(to: other) {
                    return true
                }
            }
        }
        return false
    }

    func addIfNeeded(_ decl: DeclSyntax?, to declarations: inout [DeclSyntax]) {
        guard let decl else { return }

        if let fn = decl.as(FunctionDeclSyntax.self) {
            if !hasMemberFunction(equvalentTo: fn) {
                declarations.append(decl)
            }
        } else if let property = decl.as(VariableDeclSyntax.self) {
            if !hasMemberProperty(equivalentTo: property) {
                declarations.append(decl)
            }
        }
    }
}

extension AttributeSyntax {
    var availability: AttributeSyntax? {
        if attributeName.identifier == "available" {
            return self
        } else {
            return nil
        }
    }
}

extension IfConfigClauseSyntax.Elements {
    var availability: IfConfigClauseSyntax.Elements? {
        switch self {
        case .attributes(let attributes):
            if let availability = attributes.availability {
                return .attributes(availability)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

extension IfConfigClauseSyntax {
    var availability: IfConfigClauseSyntax? {
        if let availability = elements?.availability {
            return with(\.elements, availability)
        } else {
            return nil
        }
    }

    var clonedAsIf: IfConfigClauseSyntax {
        detached.with(\.poundKeyword, .poundIfToken())
    }
}

extension IfConfigDeclSyntax {
    var availability: IfConfigDeclSyntax? {
        var elements = [IfConfigClauseListSyntax.Element]()
        for clause in clauses {
            if let availability = clause.availability {
                if elements.isEmpty {
                    elements.append(availability.clonedAsIf)
                } else {
                    elements.append(availability)
                }
            }
        }
        if elements.isEmpty {
            return nil
        } else {
            return with(\.clauses, IfConfigClauseListSyntax(elements))
        }
    }
}

extension AttributeListSyntax.Element {
    var availability: AttributeListSyntax.Element? {
        switch self {
        case .attribute(let attribute):
            if let availability = attribute.availability {
                return .attribute(availability)
            }
        case .ifConfigDecl(let ifConfig):
            if let availability = ifConfig.availability {
                return .ifConfigDecl(availability)
            }
        @unknown default:
            break
        }

        return nil
    }
}

extension AttributeListSyntax {
    var availability: AttributeListSyntax? {
        var elements = [AttributeListSyntax.Element]()
        for element in self {
            if let availability = element.availability {
                elements.append(availability)
            }
        }
        if elements.isEmpty {
            return nil
        }

        return AttributeListSyntax(elements)
    }
}
