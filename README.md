<p align="center">
  <img src="https://raw.githubusercontent.com/sunilsharma08/XNLogger/networkLoggerUI/XNLoggerLogo.png" title="XNLogger logo"    float=left width="600">
</p>

[![License](https://img.shields.io/github/license/sunilsharma08/XNLogger?color=blue)](https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/LICENSE)
[![Pod version](https://img.shields.io/cocoapods/v/XNLogger)](https://cocoapods.org/pods/XNLogger)
[![Pod platforms](https://img.shields.io/cocoapods/p/XNLogger)](https://cocoapods.org/pods/XNLogger)
[![Swift version](https://img.shields.io/badge/Swift-5.0-orange)](https://swift.org/getting-started/#installing-swift)
</br>
Framework to log network request and response. An easy way to view and debug REST API request and response error. Logs can be viewed in In-App and also logs can be written on file or send to server. This framework also provides a simple way to format log data so that there will be less impact on App due to logger and avoid writing unnecessary data.

# Features
* Logs all network traffics.
* Filters for scheme(http, https), host(www.example.com), contains(any string in url).
* Mutiple log writer/handlers support(e.g. console, file, etc.), more than one handlers can be used simultaneously.
* Support for custom log handlers.
* Separate filters can be added for each log handlers.
* Skip completely XNLogger or skip some url for a specific log handelr.
* Dynamically filters and log handlers can be added or removed.
* Log formatter to log desired data only.
* Network logs can be viewed In-App, by default shake gesture present XNLogger UI.

# Example Screenshots
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
