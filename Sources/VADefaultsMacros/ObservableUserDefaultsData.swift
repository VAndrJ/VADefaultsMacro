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
    // https://github.com/swiftlang/swift/blob/252a57a3fddb5da502d5bae1b780d1d3aa999df0/lib/Macros/Sources/ObservationMacros/ObservableMacro.swift#L17
    static let moduleName = "Observation"

    static let conformanceName = "Observable"
    static var qualifiedConformanceName: String {
        return "\(moduleName).\(conformanceName)"
    }

    static var observableConformanceType: TypeSyntax {
        "\(raw: qualifiedConformanceName)"
    }

    static let registrarTypeName = "ObservationRegistrar"
    static var qualifiedRegistrarTypeName: String {
        return "\(moduleName).\(registrarTypeName)"
    }

    static let trackedMacroName = "ObservationDefaultsTracked"
    static let ignoredMacroName = "ObservationIgnored"

    static let registrarVariableName = "_$observationRegistrar"

    static func registrarVariable(_ observableType: TokenSyntax) -> DeclSyntax {
        return
            """
            @\(raw: ignoredMacroName) private let \(raw: registrarVariableName) = \(raw: qualifiedRegistrarTypeName)()
            """
    }

    static func accessFunction(_ observableType: TokenSyntax) -> DeclSyntax {
        return
            """
            internal nonisolated func access<Member>(
            keyPath: KeyPath<\(observableType), Member>
            ) {
            \(raw: registrarVariableName).access(self, keyPath: keyPath)
            }
            """
    }

    static func withMutationFunction(_ observableType: TokenSyntax) -> DeclSyntax {
        return
            """
            internal nonisolated func withMutation<Member, MutationResult>(
            keyPath: KeyPath<\(observableType), Member>,
            _ mutation: () throws -> MutationResult
            ) rethrows -> MutationResult {
            try \(raw: registrarVariableName).withMutation(of: self, keyPath: keyPath, mutation)
            }
            """
    }

    static var ignoredAttribute: AttributeSyntax {
        AttributeSyntax(
            leadingTrivia: .space,
            atSign: .atSignToken(),
            attributeName: IdentifierTypeSyntax(name: .identifier(ignoredMacroName)),
            trailingTrivia: .space
        )
    }
}

struct ObservationDiagnostic: DiagnosticMessage {
    enum ID: String {
        case invalidApplication = "invalid type"
        case missingInitializer = "missing initializer"
    }

    var message: String
    var diagnosticID: MessageID
    var severity: DiagnosticSeverity

    init(
        message: String, diagnosticID: SwiftDiagnostics.MessageID,
        severity: SwiftDiagnostics.DiagnosticSeverity = .error
    ) {
        self.message = message
        self.diagnosticID = diagnosticID
        self.severity = severity
    }

    init(
        message: String, domain: String, id: ID,
        severity: SwiftDiagnostics.DiagnosticSeverity = .error
    ) {
        self.message = message
        self.diagnosticID = MessageID(domain: domain, id: id.rawValue)
        self.severity = severity
    }
}

extension DiagnosticsError {
    init<S: SyntaxProtocol>(
        syntax: S, message: String, domain: String = "Observation", id: ObservationDiagnostic.ID,
        severity: SwiftDiagnostics.DiagnosticSeverity = .error
    ) {
        self.init(diagnostics: [
            Diagnostic(
                node: Syntax(syntax),
                message: ObservationDiagnostic(
                    message: message, domain: domain, id: id, severity: severity))
        ])
    }
}

extension DeclModifierListSyntax {
    func privatePrefixed(_ prefix: String) -> DeclModifierListSyntax {
        let modifier: DeclModifierSyntax = DeclModifierSyntax(
            name: "private", trailingTrivia: .space)
        return [modifier]
            + filter {
                switch $0.name.tokenKind {
                case .keyword(let keyword):
                    switch keyword {
                    case .fileprivate, .private, .internal, .package, .public:
                        return false
                    default:
                        return true
                    }
                default:
                    return true
                }
            }
    }

    init(keyword: Keyword) {
        self.init([DeclModifierSyntax(name: .keyword(keyword))])
    }
}

extension TokenSyntax {

    func privatePrefixed(_ prefix: String) -> TokenSyntax {
        switch tokenKind {
        case .identifier(let identifier):
            return TokenSyntax(
                .identifier(prefix + identifier), leadingTrivia: leadingTrivia,
                trailingTrivia: trailingTrivia, presence: presence)
        default:
            return self
        }
    }
}

extension PatternBindingListSyntax {

    func privatePrefixed(_ prefix: String) -> PatternBindingListSyntax {
        var bindings = self.map { $0 }
        for index in 0..<bindings.count {
            let binding = bindings[index]
            if let identifier = binding.pattern.as(IdentifierPatternSyntax.self) {
                bindings[index] = PatternBindingSyntax(
                    leadingTrivia: binding.leadingTrivia,
                    pattern: IdentifierPatternSyntax(
                        leadingTrivia: identifier.leadingTrivia,
                        identifier: identifier.identifier.privatePrefixed(prefix),
                        trailingTrivia: identifier.trailingTrivia
                    ),
                    typeAnnotation: binding.typeAnnotation,
                    initializer: binding.initializer,
                    accessorBlock: binding.accessorBlock,
                    trailingComma: binding.trailingComma,
                    trailingTrivia: binding.trailingTrivia
                )
            }
        }

        return PatternBindingListSyntax(bindings)
    }
}

extension VariableDeclSyntax {
    func privatePrefixed(
        _ prefix: String,
        addingAttribute attribute: AttributeSyntax
    ) -> VariableDeclSyntax {
        let newAttributes = attributes + [.attribute(attribute)]

        return VariableDeclSyntax(
            leadingTrivia: leadingTrivia,
            attributes: newAttributes,
            modifiers: modifiers.privatePrefixed(prefix),
            bindingSpecifier: TokenSyntax(
                bindingSpecifier.tokenKind,
                leadingTrivia: .space,
                trailingTrivia: .space,
                presence: .present
            ),
            bindings: bindings.privatePrefixed(prefix),
            trailingTrivia: trailingTrivia
        )
    }

    var isValidForObservation: Bool {
        !isComputed && isInstance && !isImmutable && identifier != nil
    }
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
        guard let identified = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }

        let observableType = identified.name.trimmed

        if declaration.isEnum {
            // enumerations cannot store properties
            throw DiagnosticsError(
                syntax: node,
                message:
                    "'@Observable' cannot be applied to enumeration type '\(observableType.text)'",
                id: .invalidApplication)
        }
        if declaration.isStruct {
            // structs are not yet supported; copying/mutation semantics tbd
            throw DiagnosticsError(
                syntax: node,
                message: "'@Observable' cannot be applied to struct type '\(observableType.text)'",
                id: .invalidApplication)
        }
        if declaration.isActor {
            // actors cannot yet be supported for their isolation
            throw DiagnosticsError(
                syntax: node,
                message: "'@Observable' cannot be applied to actor type '\(observableType.text)'",
                id: .invalidApplication)
        }

        let labeledExprListSyntax = node.arguments?.as(LabeledExprListSyntax.self)
        let defaults = labeledExprListSyntax?.defaultsParam ?? .standardDefaults
        let modifier: String
        if let initModifier = declaration.as(ClassDeclSyntax.self)?.modifiers.initModifier {
            modifier = initModifier
        } else {
            throw UserDefaultsValueError.classOfStructNeeded
        }

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
        guard let property = member.as(VariableDeclSyntax.self), property.isValidForObservation,
            property.identifier != nil
        else {
            return []
        }

        // dont apply to ignored properties or properties that are already flagged as tracked
        if property.hasMacroApplication(ObservableUserDefaultsData.ignoredMacroName)
            || property.hasMacroApplication(ObservableUserDefaultsData.trackedMacroName)
        {
            return []
        }

        return [
            "@\(raw: String(describing: DefaultsValue.self))",
            AttributeSyntax(
                attributeName: IdentifierTypeSyntax(
                    name: .identifier(ObservableUserDefaultsData.trackedMacroName))),
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
        // This method can be called twice - first with an empty `protocols` when
        // no conformance is needed, and second with a `MissingTypeSyntax` instance.
        if protocols.isEmpty {
            return []
        }

        let decl: DeclSyntax = """
            extension \(raw: type.trimmedDescription): \(raw: qualifiedConformanceName) {}
            """
        let ext = decl.cast(ExtensionDeclSyntax.self)

        if let availability = declaration.attributes.availability {
            return [ext.with(\.attributes, availability)]
        } else {
            return [ext]
        }
    }
}

extension VariableDeclSyntax {
    var identifierPattern: IdentifierPatternSyntax? {
        bindings.first?.pattern.as(IdentifierPatternSyntax.self)
    }

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

    var identifier: TokenSyntax? {
        identifierPattern?.identifier
    }

    var type: TypeSyntax? {
        bindings.first?.typeAnnotation?.type
    }

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

    var willSetAccessors: [AccessorDeclSyntax] {
        accessorsMatching { $0 == .keyword(.willSet) }
    }
    var didSetAccessors: [AccessorDeclSyntax] {
        accessorsMatching { $0 == .keyword(.didSet) }
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

    var isImmutable: Bool {
        return bindingSpecifier.tokenKind == .keyword(.let)
    }

    func isEquivalent(to other: VariableDeclSyntax) -> Bool {
        if isInstance != other.isInstance {
            return false
        }
        return identifier?.text == other.identifier?.text
    }

    var initializer: InitializerClauseSyntax? {
        bindings.first?.initializer
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
            isInstance: isInstance, identifier: name.text, parameters: parameters,
            returnType: returnType)
    }

    func isEquivalent(to other: FunctionDeclSyntax) -> Bool {
        return signatureStandin == other.signatureStandin
    }
}

extension DeclGroupSyntax {
    var memberFunctionStandins: [FunctionDeclSyntax.SignatureStandin] {
        var standins = [FunctionDeclSyntax.SignatureStandin]()
        for member in memberBlock.members {
            if let function = member.decl.as(FunctionDeclSyntax.self) {
                standins.append(function.signatureStandin)
            }
        }
        return standins
    }

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

    var definedVariables: [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            if let variableDecl = member.decl.as(VariableDeclSyntax.self) {
                return variableDecl
            }
            return nil
        }
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

    var isClass: Bool {
        return self.is(ClassDeclSyntax.self)
    }

    var isActor: Bool {
        return self.is(ActorDeclSyntax.self)
    }

    var isEnum: Bool {
        return self.is(EnumDeclSyntax.self)
    }

    var isStruct: Bool {
        return self.is(StructDeclSyntax.self)
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
