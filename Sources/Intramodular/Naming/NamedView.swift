//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public protocol opaque_NamedView {
    var name: ViewName { get }
}

public struct NamedView<V: View>: opaque_NamedView, View {
    public let view: V
    public let name: ViewName
    
    fileprivate init(view: V, name: ViewName) {
        self.view = view
        self.name = name
    }
    
    public var body: some View {
        environment(\.viewName, name).anchorPreference(
            key: ArrayReducePreferenceKey<ViewNamePreferenceKeyValue>.self,
            value: .bounds
        ) {
            [.init(name: self.name, bounds: $0)]
        }
    }
}

// MARK: - API -

extension View {
    /// Set a name for `self`.
    public func name(_ name: ViewName) -> NamedView<Self> {
        NamedView(view: self, name: name)
    }
    
    /// Set a name for `self`.
    public func name<H: Hashable>(_ name: H) -> NamedView<Self> {
        self.name(ViewName(name))
    }
}

// MARK: - Helpers -

/// A version of `AnyView` that exposes the view's name if possible.
public struct AnyNamedOrUnnamedView: View {
    public let view: AnyView
    public let name: ViewName?
    
    public init<V: View>(_ view: V) {
        self.view = view.eraseToAnyView()
        self.name = (view as? opaque_NamedView)?.name
    }
    
    public var body: some View {
        view
    }
}
