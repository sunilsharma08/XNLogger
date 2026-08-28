<p align="center">
  <img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerLogo.jpg" title="XNLogger logo"    float=left width="600">
</p>

[![Swift version](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org/getting-started/#installing-swift)
[![Pod version](https://img.shields.io/cocoapods/v/XNLogger)](https://github.com/sunilsharma08/XNLogger)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/sunilsharma08/XNLogger)
[![License](https://img.shields.io/github/license/sunilsharma08/XNLogger?color=blue)](https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/LICENSE)
[![Pod platforms](https://img.shields.io/cocoapods/p/XNLogger)](https://github.com/sunilsharma08/XNLogger)
<br/>
<br/>

A lightweight, extensible network logging framework for iOS. Log every HTTP request and response with zero configuration changes to your networking code.

## Table of Contents

- [Why XNLogger?](#why-xnlogger)
- [Screenshots](#screenshots)
- [Quick Start](#quick-start)
- [Requirements](#requirements)
- [Installation](#installation)
- [Features](#features)
- [Usage](#usage)
  - [Start / Stop Logging](#start--stop-logging)
  - [Viewing Logs](#viewing-logs)
  - [SwiftUI Support](#swiftui-support)
  - [Log Handlers](#log-handlers)
  - [Filters](#filters)
  - [Formatters](#formatters)
  - [Observing Logs](#observing-logs)
- [Limitations](#limitations)
- [Contributing](#contributing)
- [License](#license)

## Why XNLogger?

- **Zero-config interception** -- works with `URLSession`, Alamofire, and AFNetworking out of the box, no code changes needed in your networking layer.
- **Memory-efficient** -- logs are written to disk, not held in memory, preventing crashes from large binary payloads (images, videos, etc.).
- **Multiple simultaneous handlers** -- log to Xcode console, file, Slack, a remote server, or your own custom handler -- all at once.
- **Modern Swift** -- Swift 6 concurrency safe, AsyncStream observation, Combine publisher, and SwiftUI-first UI.
- **In-app debugging UI** -- shake your device or press a keyboard shortcut to browse, search, and share network logs with a built-in inspector.

# Screenshots
<table>
  <tr>
    <th>Network Log list</th>
    <th>Request details</th>
    <th>Response details</th>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/LogListScreen.png" alt="Log lists" width="300" height="468"/></td>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/LogDetailsRequestScreen.png" alt="Request details" width="300" height="468"/></td>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/LogDetailsResponseScreen.png" alt="Response details" width="300" height="468"/></td>
  </tr>
  <tr>
    <th>Share</th>
    <th>Multimedia preview</th>
    <th>Mini view mode (PIP)</th>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/Share.png" alt="Share logs" width="300" height="468"/></td>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/MultimediaContent.png" alt="Multimedia preview" width="300" height="468"/></td>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/MiniView.png" alt="Mini view mode" width="300" height="468"/></td>
  </tr>
</table>

## Quick Start

```swift
// 1. Start logging (in AppDelegate or @main App init)
#if DEBUG
XNLogger.shared.startLogging()
#endif

// 2. That's it! Shake your device or press Ctrl+X in the Simulator to view logs.

// Optional: Add a console handler to also print logs in Xcode console
let consoleHandler = XNConsoleLogHandler.create()
XNLogger.shared.addLogHandlers([consoleHandler])
```

For **SwiftUI** apps, attach the logger sheet to your root view:

```swift
@main
struct MyApp: App {
    init() {
        #if DEBUG
        XNLogger.shared.startLogging()
        XNUIManager.shared.startGesture = .none // Use SwiftUI shake instead of UIKit
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .xnLoggerSheet() // Shows logger UI on device shake
        }
    }
}
```

## Requirements

iOS 15.0 or later

# Installation

## CocoaPods
```ruby
pod 'XNLogger'
```

To integrate only for `debug` configuration:
```ruby
pod 'XNLogger', :configurations => ['Debug']
```

## Swift Package Manager
Add XNLogger to your project via Xcode:
1. Go to **File > Add Package Dependencies**
2. Enter the repository URL: `https://github.com/sunilsharma08/XNLogger.git`
3. Choose your version rules (e.g., "Up to Next Major" from 3.1.0)

> **Note:** When using SPM, auto-start is not available. You must manually call `XNLogger.shared.startLogging()`. See [Quick Start](#quick-start).

## Carthage
```
github "https://github.com/sunilsharma08/XNLogger"
```

## Manually

Drag the folder "XNLogger" with the source files into your project.

- Remove file called "Info.plist" inside folder "XNLogger", you might get error due to this.
- Go to file "XNLoader.m" and replace import statement from `"XNLogger/XNLogger-Swift.h"` to `<Your-app-target-name>-Swift.h`.
For example your app target name is AwesomeApp, then import statement will be
```objc
#import "AwesomeApp-Swift.h"
```

For more details on how to bridge swift code in Objective-C file check this apple doc - [Importing Swift into Objective-C](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_swift_into_objective-c)

## Debug-Only Integration

To ensure XNLogger is completely excluded from release builds:

**CocoaPods:**
```ruby
pod 'XNLogger', :configurations => ['Debug']
```

**SPM / Carthage / Manual** -- wrap all XNLogger usage in `#if DEBUG`:
```swift
#if DEBUG
import XNLogger
#endif
```

# Features

### Core
- [x] Logs all network traffic automatically via `URLSession` interception
- [x] Works with Alamofire & AFNetworking without extra configuration
- [x] Memory-efficient disk-based logging to prevent crashes from large payloads
- [x] Swift 6 concurrency safe (`Sendable` conformance throughout)
- [x] Swift & Objective-C compatibility

### UI
- [x] In-app log browser via shake gesture or `Ctrl+X` keyboard shortcut
- [x] Mini view mode (picture-in-picture) -- resizable and draggable
- [x] Share logs via email, AirDrop, or clipboard
- [x] Save log files to desktop when running on Simulator
- [x] SwiftUI support with `.xnLoggerSheet()` modifier and `XNLoggerView()`
- [x] iPhone and iPad support

### Handlers
- [x] Built-in handlers: Console, File, Remote, Slack
- [x] Multiple handlers can run simultaneously
- [x] Custom handler support via `XNLogHandler` protocol
- [x] Per-handler filters -- each handler can have independent filter rules

### Observation
- [x] AsyncStream-based log observation for Swift concurrency
- [x] Combine publisher for reactive log observation
- [x] Delegate-based callbacks (`XNLoggerDelegate`)

### Filtering & Formatting
- [x] Filters by scheme (`http`, `https`), host (`www.example.com`), or substring match
- [x] Invert any filter to exclude instead of include
- [x] Filters can be added or removed dynamically at runtime
- [x] Log formatter to control exactly which fields are logged

# Usage

## Start / Stop Logging

With CocoaPods, logging starts automatically after integration. With SPM, Carthage, or manual integration, call `startLogging()` in your app launch code. Press `Ctrl+X` or shake the device/simulator to view logs in-app.

### Start Logging manually
```swift
XNLogger.shared.startLogging()
```
### Stop Logging
```swift
XNLogger.shared.stopLogging()
```

To use logger only for debug builds, wrap in preprocessor macros:
```swift
#if DEBUG
    XNLogger.shared.startLogging()
#endif
```

## Viewing Logs

### Show XNLogger UI
```swift
XNUIManager.shared.presentUI()
```
### Hide XNLogger UI
```swift
XNUIManager.shared.dismissUI()
```

### Clear logs
```swift
XNUIManager.shared.clearLogs()
```

### Custom Keyboard Shortcut

By default, `Ctrl+X` toggles the logger UI in the Simulator. To use a different shortcut:

```swift
XNUIManager.shared.registerShortcutKey("d", modifierFlags: [.command])
```

## SwiftUI Support

### Shake-triggered logger sheet
Attach the `.xnLoggerSheet()` modifier to your root view. The logger UI will appear as a sheet when the device is shaken.

```swift
@main
struct MyApp: App {
    init() {
        XNLogger.shared.startLogging()
        // Disable UIKit shake gesture to avoid duplicate UI
        XNUIManager.shared.startGesture = .none
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .xnLoggerSheet()
        }
    }
}
```

### Present logger manually
Use `XNLoggerView()` directly in a `.sheet()` or `.fullScreenCover()`:

```swift
@State private var showLogger = false

var body: some View {
    Button("Show Logs") { showLogger = true }
        .sheet(isPresented: $showLogger) {
            XNLoggerView()
        }
}
```

## Log Handlers

XNLogger ships with four built-in handlers. You can use any combination simultaneously.

| Handler | Class | Purpose |
|---------|-------|---------|
| Console | `XNConsoleLogHandler` | Prints logs to Xcode console |
| File | `XNFileLogHandler` | Writes logs to rotating files on disk |
| Remote | `XNRemoteLogHandler` | Sends logs via HTTP POST to a custom server |
| Slack | `XNSlackLogHandler` | Posts logs to a Slack channel via webhook |

### Console Handler
```swift
let consoleHandler = XNConsoleLogHandler.create()
XNLogger.shared.addLogHandlers([consoleHandler])
```

### File Handler
```swift
let fileHandler = XNFileLogHandler.create() // Default file name: "XNNetworkLog"
// Or with a custom file name:
let fileHandler = XNFileLogHandler.create(fileName: "AppNetworkLogs")

// Configuration (optional)
fileHandler.maxFileSize = 1024   // Max file size in KB (default: 1024 = 1 MB)
fileHandler.maxFileCount = 4     // Max number of rotated log files (default: 4)

XNLogger.shared.addLogHandlers([fileHandler])
```

### Remote Handler

Send logs to your own server. The handler appends log content to the HTTP body of the provided `URLRequest` under the key `"xn-log-msg"`.

```swift
var request = URLRequest(url: URL(string: "https://your-server.com/logs")!)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let remoteHandler = XNRemoteLogHandler.create(urlRequest: request)
XNLogger.shared.addLogHandlers([remoteHandler])
```

> Requests made by the Remote handler are excluded from XNLogger interception, so they will not appear in your logs.

### Slack Handler

Send logs directly to a Slack channel using an [Incoming Webhook URL](https://api.slack.com/messaging/webhooks).

```swift
let slackHandler = XNSlackLogHandler.create(
    webhookUrl: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
)
XNLogger.shared.addLogHandlers([slackHandler])
```

> Requests made by the Slack handler are excluded from XNLogger interception.

### Custom Handler

Create your own handler by conforming to the `XNLogHandler` protocol. Subclassing `XNBaseLogHandler` is recommended as it provides filter management and the `shouldLogRequest` / `shouldLogResponse` convenience methods.

```swift
class MyCustomHandler: XNBaseLogHandler, XNLogHandler {

    static func create() -> MyCustomHandler {
        return MyCustomHandler()
    }

    func xnLogger(logRequest logData: XNLogData) {
        guard shouldLogRequest(logData: logData) else { return }
        // Handle request
        print("Request to: \(logData.urlRequest.url?.absoluteString ?? "")")
    }

    func xnLogger(logResponse logData: XNLogData) {
        guard shouldLogResponse(logData: logData) else { return }
        // Handle response
        let status = (logData.response as? HTTPURLResponse)?.statusCode ?? 0
        print("Response [\(status)]")
    }
}

XNLogger.shared.addLogHandlers([MyCustomHandler.create()])
```

### Remove Handlers
```swift
XNLogger.shared.removeHandlers([consoleHandler])
// Or remove all:
XNLogger.shared.removeAllHandlers()
```

## Filters

Filters control which network requests are logged. They can be applied at two levels:

- **Logger-level** (`XNLogger.shared.addFilters`) -- requests that don't pass are completely ignored by all handlers and do not appear in the in-app UI.
- **Handler-level** (`handler.addFilters`) -- requests are still recorded but only logged by handlers whose filters they pass. Filters on one handler do not affect other handlers.

### Available Filters

| Filter | Class | Matches |
|--------|-------|---------|
| Scheme | `XNSchemeFilter(scheme:)` | URL scheme (`http`, `https`) |
| Host | `XNHostFilter(host:)` | URL host (`www.example.com`) |
| Contains | `XNContainsFilter(filterString:)` | Any substring in the full URL |

### Add filters to logger (universal)
```swift
let httpsOnly = XNSchemeFilter(scheme: "https")
XNLogger.shared.addFilters([httpsOnly])
```

### Remove filters from logger
```swift
XNLogger.shared.removeFilters([httpsOnly])
```

### Add filters to a specific handler
```swift
let host = XNHostFilter(host: "www.example.com")
consoleHandler.addFilters([host])
```

### Remove filters from handler
```swift
consoleHandler.removeFilters([host])
```

### Contains Filter

Filter by any substring in the URL:
```swift
let apiFilter = XNContainsFilter(filterString: "/api/v2/")
XNLogger.shared.addFilters([apiFilter])
```

### Inverting Filters

Any filter can be inverted to **exclude** matching URLs instead of including them:
```swift
let excludeHTTP = XNSchemeFilter(scheme: "http", invert: true)
// Logs only HTTPS requests
```

Or set the property after creation:
```swift
let filter = XNSchemeFilter(scheme: "http")
filter.invert = true
```

## Formatters
By default, the logger logs all information except binary data. These settings can be adjusted per requirement. The formatter controls what fields to log and what to skip.

Formatter class `XNLogFormatter` has the following properties:
```swift
public var showRequest: Bool = true // Hide or show requests log.
public var showResponse: Bool = true // Hide or show response log.
public var showReqstWithResp: Bool = false // Show request with response, useful when `showRequest` is disabled.
public var showCurlWithReqst: Bool = true // Show curl request with request log.
public var showCurlWithResp: Bool = true // Show curl request when url request is displayed with response.
public var prettyPrintJSON: Bool = true // Log pretty printed json data.
public var logUnreadableRespBody: Bool = false // Show binary data like image, video, etc in response.
public var logUnreadableReqstBody: Bool = false // Show binary data like image, video, etc in request body.
public var showReqstMetaInfo: [XNRequestMetaInfo] = XNRequestMetaInfo.allCases // Details to be displayed in request log portion.
public var showRespMetaInfo: [XNResponseMetaInfo] = XNResponseMetaInfo.allCases // Details to be displayed in response log portion.
public var showReqstMetaInfoWithResp: [XNRequestMetaInfo] = XNRequestMetaInfo.allCases // Details to display for request when display as response portion.
```

## Observing Logs

### AsyncStream

Use `logStream` to observe log events with Swift concurrency. Each caller gets an independent stream that auto-cancels when the `Task` is cancelled.

```swift
.task {
    for await event in XNLogger.shared.logStream {
        switch event {
        case .request(let logData):
            print("Request: \(logData.urlRequest.url?.absoluteString ?? "")")
        case .response(let logData):
            let status = (logData.response as? HTTPURLResponse)?.statusCode
            print("Response [\(status ?? 0)]: \(logData.urlRequest.url?.absoluteString ?? "")")
        }
    }
}
```

### Combine

Use `logPublisher` to subscribe to log events reactively:

```swift
import Combine

var cancellables = Set<AnyCancellable>()

XNLogger.shared.logPublisher
    .sink { event in
        switch event {
        case .request(let logData):
            print("Request: \(logData.urlRequest.url?.absoluteString ?? "")")
        case .response(let logData):
            print("Response: \(logData.urlRequest.url?.absoluteString ?? "")")
        }
    }
    .store(in: &cancellables)
```

### Delegate

For traditional callback-based observation, use `XNLoggerDelegate`:

```swift
class NetworkMonitor: NSObject, XNLoggerDelegate {

    func startMonitoring() {
        XNLogger.shared.delegate = self
    }

    func xnLogger(didStartRequest logData: XNLogData) {
        print("Started: \(logData.urlRequest.url?.absoluteString ?? "")")
    }

    func xnLogger(didReceiveResponse logData: XNLogData) {
        let status = (logData.response as? HTTPURLResponse)?.statusCode ?? 0
        print("Completed [\(status)]: \(logData.urlRequest.url?.absoluteString ?? "")")
    }
}
```

> **Note:** The delegate is a `weak` property. Only one delegate can be active at a time. For multiple observers, use `logStream` or `logPublisher` instead.

## Limitations
1. Does not log background URLSession tasks.
2. WKWebView URLs will not be logged.

Working on logging background tasks and WKWebView URLs without using any private API. These limitations may be removed in future releases.

# Contributing
Feel free to raise a PR for any bug fixes, features, or enhancements. When you are done with changes, raise a PR to the `develop` branch.

Another way to contribute to the project is to send a detailed issue when you encounter a problem. In bug details please provide steps to reproduce and some other details like Swift version, URL (if possible), URLSession configuration, etc.

# License
XNLogger is available under the [MIT license](https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/LICENSE).
