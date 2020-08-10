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

During development and testing phase on various occasion we just want to see REST API's response to verify data, just for this we may have to write prints statements on various location or put break points or instead we can use XNLogger. It can write network logs on files, print on Xcode console or use inbuild logger UI. To see logs shake device or simultaor.

As we know network logs can be huge and this can pressure and memory and may result in app crash to avoid such situation it design to memory efficient, it write logs on disk on requirement loads in memory. 

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
- [x] Also works with external libraries like Alamofire & AFNetworking.


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

# Installtion
## Cocoapods
```
use_frameworks!
pod 'XNLogger'
```
To integrate with project only for `debug` configuration
```
use_frameworks!
pod 'XNLogger', :configurations => ['Debug']
```

## Manually

Drag the folder "XNLogger" with the source files into your project.

# Usage
It starts logging automatically after integrating library in your project. **Shake to see logs in app** or manually click on button "Show XNLogger".

### Manually Start Logging
```swift
XNLogger.shared.startLogging()
```
### Stop Logging
```swift
XNLogger.shared.stopLogging()
```
It's safe to call `startLogging` or `stopLogging` multiple times. These methods can be called from anywhere in the code.

### Add Predefined Log Handlers
```swift
let consoleLogHandler = XNConsoleLogHandler.create()
XNLogger.shared.addLogHandlers([consoleLogHandler])
```

### Remove Added Log Handlers
```swift
XNLogger.shared.removeHandlers([consoleLogHandler])
```

# License
XNLogger is available under the [MIT license](https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/LICENSE).
