<p align="center">
  <img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/networkLoggerUI/XNLoggerLogo.png" title="XNLogger logo"    float=left width="600">
</p>

[![Swift version](https://img.shields.io/badge/Swift-5.0-orange)](https://swift.org/getting-started/#installing-swift)
[![Pod version](https://img.shields.io/cocoapods/v/XNLogger)](https://github.com/sunilsharma08/XNLogger)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/sunilsharma08/XNLogger)
[![License](https://img.shields.io/github/license/sunilsharma08/XNLogger?color=blue)](https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/LICENSE)
[![Pod platforms](https://img.shields.io/cocoapods/p/XNLogger)](https://github.com/sunilsharma08/XNLogger)

</br>
XNLogger is network logging framework, which can be easily extended and modified as per requirements. It can be formatted to log just url or complete network traffic details. It provides in-app logger UI for debugging and testing purpose.

Logs can be written on files, print on Xcode console, send to network or use inbuild logger UI. Network logger UI appears in app with shake gesture on device and simulators.

Network loggers can generate huge data specially when binary data(like image, video, etc.) logging is enabled, this can increase memory usage and may result in app crash. To avoid such situation XNLogger is designed to use memory efficiently, it write logs on disk and only on requirement loads in memory. 

# Features
- [x] Logs all network traffics.
- [x] Network logs can be viewed In-App, by default shake gesture present XNLogger UI.
- [x] Mini view mode, makes debugging easier. Mini view can be resized and moved on screen.
- [x] Share network logs via email, airdrop or copy to clipboard.
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
- [x] Works with iPhone and iPad.


# Screenshots
<table>
  <tr>
    <th>Network Log list</th>
    <th>Request details</th>
    <th>Response details</th>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/LogListScreen.png" alt="Grid Menu" width="300" height="468"/></td>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/LogDetailsRequestScreen.png" alt="Circular Menu" width="300" height="468"/></td>
    <td><img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/LogDetailsResponseScreen.png" alt="Grid Menu" width="300" height="468"/></td>
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
Logging starts automatically after integration in project. Shake device or simulator to see logs in app.

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

# License
XNLogger is available under the [MIT license](https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/LICENSE).
