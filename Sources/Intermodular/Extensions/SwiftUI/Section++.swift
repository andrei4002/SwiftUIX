//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Section {
    public var header: Parent {
        Mirror(reflecting: self).children.first(where: { $0.label == "header" })?.value as! Parent
    }
    
    public var content: Content {
        Mirror(reflecting: self).children.first(where: { $0.label == "content" })?.value as! Content
    }
    
    public var footer: Footer {
        Mirror(reflecting: self).children.first(where: { $0.label == "footer" })?.value as! Footer
    }
}

extension Section where Parent: View, Content: View, Footer: View {
    public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Parent,
        @ViewBuilder footer: () -> Footer
    ) {
        self.init(header: header(), footer: footer(), content: content)
    }
}

extension Section where Parent == Text, Content: View, Footer == EmptyView {
    public init<S: StringProtocol>(header: S, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), content: content)
    }
    
    public init<S: StringProtocol>(_ header: S, @ViewBuilder content: () -> Content) {
        self.init(header: header, content: content)
    }
}

extension Section where Parent == Text, Content: View, Footer == Text {
    public init<S: StringProtocol>(
        header: S,
        footer: S,
        @ViewBuilder content: () -> Content
    ) {
        self.init(header: Text(header), footer: Text(footer), content: content)
    }
}
