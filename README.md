<p align="center">
  <img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerLogo.jpg" title="XNLogger logo"    float=left width="600">
</p>

[![Swift version](https://img.shields.io/badge/Swift-5.0-orange)](https://swift.org/getting-started/#installing-swift)
[![Pod version](https://img.shields.io/cocoapods/v/XNLogger)](https://github.com/sunilsharma08/XNLogger)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/sunilsharma08/XNLogger)
[![License](https://img.shields.io/github/license/sunilsharma08/XNLogger?color=blue)](https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/LICENSE)
[![Pod platforms](https://img.shields.io/cocoapods/p/XNLogger)](https://github.com/sunilsharma08/XNLogger)
<br/>
<br/>
XNLogger is network logging framework, which can be easily extended and modified as per requirements. It can be formatted to log just url or complete network traffic details. It provides in-app logger UI for debugging and testing purpose. Logs can be written on files, print on Xcode console, send to network or use inbuild logger UI. Network logger UI appears in app with shake gesture on device and simulators.

<br/>

Network loggers can generate huge data specially when binary data(like image, video, etc.) logging is enabled, this can increase memory usage and may result in app crash. To avoid such situation XNLogger is designed to use memory efficiently, it write logs on disk and only on requirement loads in memory. 

# Features
- [x] Logs all network traffics.
- [x] Network logs can be viewed In-App by pressing `CTRL + X` or via shake gesture.
- [x] Mini view mode, makes debugging easier. Mini view can be resized and moved on screen.
- [x] Share network logs via email, airdrop or copy to clipboard.
- [x] Save logs file to desktop or any other location when running app on Simulator.
- [x] Memory efficient, logs are written to disk to reduce memory pressure.
- [x] Filters for scheme(http, https), host(www.example.com), contains(any string in url).
- [x] Mutiple log writer/handlers support(e.g. console, file, etc.), more than one handlers can be used simultaneously.
- [x] Support for custom log handlers.
- [x] Separate filters can be added for each log handlers.
- [x] Skip completely XNLogger or skip some url for a specific log handelr.
- [x] Dynamically filters and log handlers can be added or removed.
- [x] Log formatter to log desired data only.
- [x] Swift & Objective-C compatibility.
- [x] Works with external libraries like Alamofire & AFNetworking.
- [x] Supports iPhone and iPad.


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
    <th>Mini view mode(PIP)</th>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/Share.png" alt="Share logs" width="300" height="468"/></td>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/MultimediaContent.png" alt="Multimedia preview" width="300" height="468"/></td>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/MiniView.png" alt="Mini view mode" width="300" height="468"/></td>
  </tr>
</table>

## Requirements

iOS 9.0 or later

# Installation
## Cocoapods
```ruby
pod 'XNLogger'
```
To integrate with project only for `debug` configuration
```ruby
pod 'XNLogger', :configurations => ['Debug']
```

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

For more details on how to bridge swift code in Objectiv-C file check this apple doc - [Importing Swift into Objective-C](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_swift_into_objective-c)

# Usage
**Logging starts automatically after integration in project. Press `CTRL + X` or shake device/simulator(Device -> Shake) to see logs in app.**

### Start Logging manually
```swift
XNLogger.shared.startLogging()
```
### Stop Logging
```swift
XNLogger.shared.stopLogging()
```

To use logger only for debug configuration wrap logger code in preprocessor macros `#if DEBUG` as
```swift
#if DEBUG
    XNLogger.shared.startLogging()
#endif
```

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

## Add predefined log handlers
### Console handler
```swift
let consoleLogHandler = XNConsoleLogHandler.create()
XNLogger.shared.addLogHandlers([consoleLogHandler])
```

### File handler
```swift
let fileLogHandler = XNFileLogHandler.create() //Default file name 'XNNetworkLog'
// File log handler can be created with filename
let fileLogHandler = XNFileLogHandler.create(fileName: "AppNetworkLogs")

XNLogger.shared.addLogHandlers([fileLogHandler])

```

### Remove log handlers
```swift
XNLogger.shared.removeHandlers([consoleLogHandler])
```

## Filters
Filters can be applied to loggers and handlers. Filters added to loggers will be applicable to all handlers and also requests does not pass through XNLogger whereas filters added to handlers will be recorded but will be logged to only applicable handlers. Filters added to one handler are not applicable on other handlers. Addings filters to logger is useful when it is required to skip all handlers or wanted to record/skip some specific urls.

### Add filters to logger(universal filter)
```swift
let httpScheme = XNSchemeFilter(scheme: "https")
XNLogger.shared.addFilters([httpScheme])
```
### Remove filters from logger(universal filter)
```swift
XNLogger.shared.removeFilters([httpScheme])
```

### Add filters to handler
```swift
let host = XNHostFilter(host: "www.example.com")
consoleHandler.addFilters([host])
```

### Remove filters from handler
```swift
consoleHandler.removeFilters([host])
```

Any filters can be inverted, so lets suppose all `http` scheme url should not appear in log then just update filter property `invert` to `true` as:
```swift
let httpScheme = XNSchemeFilter(scheme: "https")
httpScheme.invert = true
```

## Formatters
By default logger logs all informations except binary data. These setting can be adjusted as per requirement. Formatter allows to control what fields to log and what to skip.
Formatter class `XNLogFormatter` has following properties:
```swift
public var showRequest: Bool = true // Hide or show requests log.
public var showResponse: Bool = true // Hide or show response log.
public var showReqstWithResp: Bool = false // Show request with response, useful when `showRequest` is disabled.
public var showCurlWithReqst: Bool = true // Show curl request with request log.
public var showCurlWithResp: Bool = true // Show curl request when url request is displayed with response.
public var prettyPrintJSON: Bool = true // Log pretty printed json data .
public var logUnreadableRespBody: Bool = false // Show binary data like image, video, etc in response.
public var logUnreadableReqstBody: Bool = false // Show binary data like image, video, etc in request body.
public var showReqstMetaInfo: [XNRequestMetaInfo] = XNRequestMetaInfo.allCases // Details to be displayed in request log portion.
public var showRespMetaInfo: [XNResponseMetaInfo] = XNResponseMetaInfo.allCases // Details to be displayed in response log portion.
public var showReqstMetaInfoWithResp: [XNRequestMetaInfo] = XNRequestMetaInfo.allCases // Details to display for request when display as response portion.
```

### Limitations
1. Does not log background url session tasks.
2. WKWebView urls will be not logged.

Trying to log background tasks and WKWebView urls without using any private API. These limitation may be removed in next releases.

# Contribution
Feel free to raise PR for any bug fixes, features or enchancements. When you are done with changes raise PR to develop branch.

Another way to contribute to the project is to send a detailed issue when you encounter a problem. In bug detail please provide steps to reproduce and some other details like Swift version, url(if possible), URLSession configuration, etc.

# License
XNLogger is available under the [MIT license](https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/LICENSE).
