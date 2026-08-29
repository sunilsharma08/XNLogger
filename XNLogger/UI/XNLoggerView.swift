//
//  XNLoggerView.swift
//  XNLogger
//
//  Created by Sunil Sharma.
//  Copyright © 2024 Sunil Sharma. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI

/// A SwiftUI wrapper for the XNLogger UIKit-based logger UI.
///
/// Use this directly in a `.sheet()` or `.fullScreenCover()` to present the
/// network logger from a SwiftUI app:
/// ```swift
/// @State private var showLogger = false
///
/// var body: some View {
///     Button("Show Logs") { showLogger = true }
///         .sheet(isPresented: $showLogger) {
///             XNLoggerView()
///         }
/// }
/// ```
public struct XNLoggerView: UIViewControllerRepresentable {

    public init() {}

    public func makeUIViewController(context: Context) -> UITabBarController {
        let storyboard = UIStoryboard(name: "XNUIMain", bundle: Bundle.current())
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "xnlMainTabBarController") as? UITabBarController else {
            // Fallback: return an empty tab bar controller
            return UITabBarController()
        }
        return tabBarVC
    }

    public func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {}
}

// MARK: - Shake-triggered sheet modifier

/// ViewModifier that presents XNLogger as a sheet triggered by device shake.
///
/// When the user shakes the device, the logger UI is presented as a sheet.
/// The shake gesture is detected via `UIWindow.motionEnded` and communicated
/// through a notification.
struct XNLoggerSheetModifier: ViewModifier {
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                XNLoggerView()
                    .ignoresSafeArea()
            }
            .onReceive(NotificationCenter.default.publisher(for: .xnLoggerDeviceShake)) { _ in
                isPresented.toggle()
            }
    }
}

extension View {

    /// Attaches the XNLogger UI as a sheet that appears when the device is shaken.
    ///
    /// When using this modifier, set `XNUIManager.shared.startGesture = .none`
    /// to prevent the UIKit overlay from also appearing on shake.
    ///
    /// Usage:
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     init() {
    ///         XNLogger.shared.startLogging()
    ///         XNUIManager.shared.startGesture = .none
    ///     }
    ///
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .xnLoggerSheet()
    ///         }
    ///     }
    /// }
    /// ```
    public func xnLoggerSheet() -> some View {
        modifier(XNLoggerSheetModifier())
    }
}
#endif
