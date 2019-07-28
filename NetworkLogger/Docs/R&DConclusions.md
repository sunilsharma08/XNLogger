There is two way to intercept all internet requests
1. Custom URL protocols
2. Swizzle network API's

1. Custom URL protocols
 This appraoch is easier to track only REST API call but not for response (Currently I don't know how to handle different types of request like background task, upload, file download, etc.).
 
 You have to register your Custom URL protocol class. Addtionally you have to swizzle protocolClasses getter method to track method call made via other then shared instance of URLSessionConfiguration.
 
 2. Swizzle network API's 
 This appraoch requires to lot of work but almost all cases can be covered. It require Network API's to swizzle with your own methods.

 
 Reason it does not load WKWebView and background requests
 https://stackoverflow.com/questions/34865414/custom-nsurlprotocol-subclasses-are-not-available-to-background-sessions

## Possible values for HTTP “Content-Type” header
https://stackoverflow.com/questions/23714383/what-are-all-the-possible-values-for-http-content-type-header


## Determine MIME type from Data
https://stackoverflow.com/questions/21789770/determine-mime-type-from-nsdata

## Array to store weak references
https://marcosantadev.com/swift-arrays-holding-elements-weak-references/
