import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct VADefaultsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        UserDefaultsValue.self,
        CodableUserDefaultsValue.self,
        RawUserDefaultsValue.self,
        UserDefaultsData.self,
        DefaultsValue.self,
        CodableDefaultsValue.self,
        RawDefaultsValue.self,
    ]
}
