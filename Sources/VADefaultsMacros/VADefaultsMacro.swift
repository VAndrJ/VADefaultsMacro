import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct VADefaultsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        UserDefaultValue.self,
        CodableUserDefaultValue.self,
        RawUserDefaultValue.self,
        UserDefault.self,
        DefaultValue.self,
    ]
}
