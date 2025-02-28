//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIHostingCollectionViewSupplementaryView {
    struct Configuration: Identifiable {
        struct ID: Hashable {
            let item: ItemIdentifierType?
            let section: SectionIdentifierType
        }
        
        let kind: String
        let item: ItemType?
        let section: SectionType
        let itemIdentifier: ItemIdentifierType?
        let sectionIdentifier: SectionIdentifierType
        let indexPath: IndexPath
        let viewProvider: ParentViewControllerType._SwiftUIType.ViewProvider
        let maximumSize: OptionalDimensions?
        
        var id: ID {
            .init(item: itemIdentifier, section: sectionIdentifier)
        }
    }
}

class UIHostingCollectionViewSupplementaryView<
    SectionType,
    SectionIdentifierType: Hashable,
    ItemType,
    ItemIdentifierType: Hashable,
    SectionHeaderContent: View,
    SectionFooterContent: View,
    Content: View
>: UICollectionReusableView {
    typealias ParentViewControllerType = UIHostingCollectionViewController<
        SectionType,
        SectionIdentifierType,
        ItemType,
        ItemIdentifierType,
        SectionHeaderContent,
        SectionFooterContent,
        Content
    >
    
    var configuration: Configuration?
    
    private var contentHostingController: ContentHostingController?
    
    private weak var parentViewController: ParentViewControllerType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        layoutMargins = .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let contentHostingController = contentHostingController {
            if contentHostingController.view.frame != bounds {
                contentHostingController.view.frame = bounds
                contentHostingController.view.setNeedsLayout()
            }
            
            contentHostingController.view.layoutIfNeeded()
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return contentHostingController?.systemLayoutSizeFitting(targetSize) ?? .init(width: 1, height: 1)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        guard let contentHostingController = contentHostingController else {
            return .init(width: 1, height: 1)
        }
        
        return contentHostingController.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        layoutAttributes.size = systemLayoutSizeFitting(layoutAttributes.size)
        
        return layoutAttributes
    }
}

extension UIHostingCollectionViewSupplementaryView {
    func supplementaryViewWillDisplay(
        inParent parentViewController: ParentViewControllerType?,
        isPrototype: Bool = false
    ) {
        defer {
            self.parentViewController = parentViewController
        }
        
        if let contentHostingController = contentHostingController {
            contentHostingController.update()
        } else {
            contentHostingController = ContentHostingController(base: self)
        }
        
        if let parentViewController = parentViewController {
            if contentHostingController?.parent == nil {
                contentHostingController?.move(toParent: parentViewController, ofSupplementaryView: self)
            }
        } else if !isPrototype {
            assertionFailure()
        }
    }
    
    func supplementaryViewDidEndDisplaying() {
        defer {
            self.parentViewController = nil
        }
        
        contentHostingController?.move(toParent: nil, ofSupplementaryView: self)
    }
    
    func update() {
        contentHostingController?.update()
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewSupplementaryView {
    private struct RootView: ExpressibleByNilLiteral, View {
        var configuration: Configuration?
        
        init(base: UIHostingCollectionViewSupplementaryView?) {
            configuration = base?.configuration
        }
        
        public init(nilLiteral: ()) {
            
        }
        
        public var body: some View {
            if let configuration = configuration  {
                if configuration.kind == UICollectionView.elementKindSectionHeader {
                    if SectionHeaderContent.self == Never.self {
                        EmptyView()
                    } else {
                        configuration.viewProvider.sectionHeader(configuration.section)
                            .edgesIgnoringSafeArea(.all)
                            .id(configuration.id)
                    }
                } else if configuration.kind == UICollectionView.elementKindSectionFooter {
                    if SectionFooterContent.self == Never.self {
                        EmptyView()
                    } else {
                        configuration.viewProvider.sectionFooter(configuration.section)
                            .edgesIgnoringSafeArea(.all)
                            .id(configuration.id)
                    }
                }
            }
        }
    }
    
    private class ContentHostingController: CocoaHostingController<RootView> {
        weak var base: UIHostingCollectionViewSupplementaryView?
        
        init(base: UIHostingCollectionViewSupplementaryView?) {
            self.base = base
            
            super.init(mainView: nil)
            
            update()
        }
        
        @objc required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func systemLayoutSizeFitting(
            _ targetSize: CGSize
        ) -> CGSize {
            sizeThatFits(
                in: targetSize,
                withHorizontalFittingPriority: nil,
                verticalFittingPriority: nil
            )
        }
        
        public func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority
        ) -> CGSize {
            sizeThatFits(
                in: targetSize,
                withHorizontalFittingPriority: horizontalFittingPriority,
                verticalFittingPriority: verticalFittingPriority
            )
        }
        
        func move(
            toParent parent: _opaque_UIHostingCollectionViewController?,
            ofSupplementaryView supplementaryView: UIHostingCollectionViewSupplementaryView
        ) {
            if let parent = parent {
                if let existingParent = self.parent, existingParent !== parent {
                    move(toParent: nil, ofSupplementaryView: supplementaryView)
                }
                
                if self.parent == nil {
                    self.willMove(toParent: parent)
                    parent.addChild(self)
                    supplementaryView.addSubview(view)
                    view.frame = supplementaryView.bounds
                    didMove(toParent: parent)
                } else {
                    assertionFailure()
                }
            } else {
                willMove(toParent: nil)
                view.removeFromSuperview()
                removeFromParent()
            }
        }
        
        func update() {
            guard let base = base else {
                return
            }
            
            if let currentConfiguration = mainView.configuration, let newConfiguration = base.configuration {
                guard currentConfiguration.id != newConfiguration.id else {
                    return
                }
            }
            
            mainView = .init(base: base)
            
            view.setNeedsDisplay()
        }
    }
}

extension String {
    static let hostingCollectionViewSupplementaryViewIdentifier = "UIHostingCollectionViewSupplementaryView"
}

#endif
