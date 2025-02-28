//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS)

import UIKit

public typealias AppKitOrUIKitApplication = UIApplication
public typealias AppKitOrUIKitApplicationDelegate = UIApplicationDelegate
@available(iOS 14.0, tvOS 14.0, *)
public typealias AppKitOrUIKitApplicationDelegateAdapter = UIApplicationDelegateAdaptor
public typealias AppKitOrUIKitBezierPath = UIBezierPath
public typealias AppKitOrUIKitButton = UIButton
public typealias AppKitOrUIKitColor = UIColor
public typealias AppKitOrUIKitControl = UIControl
public typealias AppKitOrUIKitControlEvent = UIControl.Event
public typealias AppKitOrUIKitEvent = UIEvent
public typealias AppKitOrUIKitFont = UIFont
public typealias AppKitOrUIKitHostingController<Content: View> = UIHostingController<Content>
public typealias AppKitOrUIKitHostingView<Content: View> = UIHostingView<Content>
public typealias AppKitOrUIKitImage = UIImage
public typealias AppKitOrUIKitLabel = UILabel
public typealias AppKitOrUIKitLayoutAxis = NSLayoutConstraint.Axis
public typealias AppKitOrUIKitLayoutGuide = UILayoutGuide
public typealias AppKitOrUIKitLayoutPriority = UILayoutPriority
public typealias AppKitOrUIKitResponder = UIResponder
public typealias AppKitOrUIKitSearchBar = UISearchBar
public typealias AppKitOrUIKitTableView = UITableView
public typealias AppKitOrUIKitTableViewController = UITableViewController
public typealias AppKitOrUIKitTextField = UITextField
public typealias AppKitOrUIKitTextView = UITextView
public typealias AppKitOrUIKitView = UIView
public typealias AppKitOrUIKitViewController = UIViewController
public typealias AppKitOrUIKitWindow = UIWindow

#endif

#if os(macOS)

import AppKit

public typealias AppKitOrUIKitApplication = NSApplication
public typealias AppKitOrUIKitApplicationDelegate = NSApplicationDelegate
@available(macOS 11, *)
public typealias AppKitOrUIKitApplicationDelegateAdapter = NSApplicationDelegateAdaptor
public typealias AppKitOrUIKitBezierPath = NSBezierPath
public typealias AppKitOrUIKitButton = NSButton
public typealias AppKitOrUIKitColor = NSColor
public typealias AppKitOrUIKitControl = NSControl
public typealias AppKitOrUIKitEvent = NSEvent
public typealias AppKitOrUIKitFont = NSFont
public typealias AppKitOrUIKitHostingController<Content: View> = NSHostingController<Content>
public typealias AppKitOrUIKitHostingView<Content: View> = NSHostingView<Content>
public typealias AppKitOrUIKitImage = NSImage
public typealias AppKitOrUIKitLabel = NSLabel
public typealias AppKitOrUIKitLayoutAxis = NSUserInterfaceLayoutOrientation
public typealias AppKitOrUIKitLayoutGuide = NSLayoutGuide
public typealias AppKitOrUIKitLayoutPriority = NSLayoutConstraint.Priority
public typealias AppKitOrUIKitResponder = NSResponder
public typealias AppKitOrUIKitSearchBar = NSSearchField
public typealias AppKitOrUIKitTableView = NSTableView
public typealias AppKitOrUIKitTextView = NSTextView
public typealias AppKitOrUIKitView = NSView
public typealias AppKitOrUIKitViewController = NSViewController
public typealias AppKitOrUIKitWindow = NSWindow

extension NSView {
    public static var layoutFittingCompressedSize: CGSize {
        .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
    
    public static var layoutFittingExpandedSize: CGSize {
        .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude) // FIXME
    }
    
    @objc open func hitTest(_ point: CGPoint, with event: NSEvent?) -> NSView? {
        hitTest(point)
    }
}

#endif

#if os(watchOS)

import UIKit
import WatchKit

public typealias AppKitOrUIKitColor = UIColor
public typealias AppKitOrUIKitFont = UIFont
public typealias AppKitOrUIKitImage = UIImage

#endif

#if targetEnvironment(macCatalyst)

@objc public protocol NSAlertProtocol: NSObjectProtocol {
    @objc var alertStyle: UInt { get set }
    @objc var messageText: String { get set }
    @objc var informativeText: String { get set }
    
    @objc func addButton(withTitle: String)
    @objc func runModal()
    
    init()
}

@objc public protocol NSOpenPanelProtocol: NSObjectProtocol {
    @objc var directoryURL: URL? { get set }
    @objc var message: String? { get set }
    @objc var prompt: String? { get set }
    @objc var allowedFileTypes: [String]? { get set }
    @objc var allowsOtherFileTypes: Bool { get set }
    @objc var canChooseDirectories: Bool { get set }
    @objc var urls: [URL] { get set }
    
    @objc func runModal()
    
    init()
}

public let NSAlert_Type = unsafeBitCast(NSClassFromString("NSAlert"), to: NSAlertProtocol.Type.self)
public let NSOpenPanel_Type = unsafeBitCast(NSClassFromString("NSOpenPanel"), to: NSOpenPanelProtocol.Type.self)

#endif

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

extension EnvironmentValues {
    var _appKitOrUIKitViewControllerBox: WeakBox<AppKitOrUIKitViewController> {
        get {
            self[DefaultEnvironmentKey<WeakBox<AppKitOrUIKitViewController>>] ?? WeakBox(nil)
        } set {
            self[DefaultEnvironmentKey<WeakBox<AppKitOrUIKitViewController>>] = newValue
        }
    }
    
    public var _appKitOrUIKitViewController: AppKitOrUIKitViewController? {
        get {
            _appKitOrUIKitViewControllerBox.value
        } set {
            _appKitOrUIKitViewControllerBox.value = newValue
        }
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public var _appKitOrUIKitWindowScene: UIWindowScene? {
        _appKitOrUIKitViewController?.view.window?.windowScene
    }
    #endif
}

struct _ResolveAppKitOrUIKitViewController: ViewModifier {
    @State var _appKitOrUIKitViewControllerBox = WeakBox<AppKitOrUIKitViewController>(nil)
    
    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return content
            .environment(\._appKitOrUIKitViewControllerBox, _appKitOrUIKitViewControllerBox)
            .environment(\.navigator, _appKitOrUIKitViewControllerBox.value?.navigationController)
            .onUIViewControllerResolution { viewController in
                if !(_appKitOrUIKitViewControllerBox.value === viewController) {
                    _appKitOrUIKitViewControllerBox = .init(viewController)
                }
            }
        #else
        return content
        #endif
    }
}

public struct AppKitOrUIKitViewControllerAdaptor<AppKitOrUIKitViewControllerType: AppKitOrUIKitViewController>: AppKitOrUIKitViewControllerRepresentable {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public typealias UIViewControllerType = AppKitOrUIKitViewControllerType
    #elseif os(macOS)
    public typealias NSViewControllerType = AppKitOrUIKitViewControllerType
    #endif
    
    private let makeAppKitOrUIKitViewControllerImpl: (Context) -> AppKitOrUIKitViewControllerType
    private let updateAppKitOrUIKitViewControllerImpl: (AppKitOrUIKitViewControllerType, Context) -> ()
    
    public init(
        _ makeAppKitOrUIKitViewController: @autoclosure @escaping () -> AppKitOrUIKitViewControllerType
    ) {
        self.makeAppKitOrUIKitViewControllerImpl = { _ in makeAppKitOrUIKitViewController() }
        self.updateAppKitOrUIKitViewControllerImpl = { _, _ in }
    }
    
    public func makeAppKitOrUIKitViewController(
        context: Context
    ) -> AppKitOrUIKitViewControllerType {
        makeAppKitOrUIKitViewControllerImpl(context)
    }
    
    public func updateAppKitOrUIKitViewController(
        _ uiViewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) {
        updateAppKitOrUIKitViewControllerImpl(uiViewController, context)
    }
}

#endif
