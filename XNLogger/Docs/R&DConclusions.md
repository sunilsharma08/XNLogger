There is two way to intercept all internet requests
1. Custom URL protocols
2. Swizzle network API's
3. Correct way to swizzle(Need to make changes in framework) - https://blog.newrelic.com/engineering/right-way-to-swizzle/

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
http://www.iana.org/assignments/media-types/media-types.xhtml
For data signature reference used in this framework
1. https://www.garykessler.net/library/file_sigs.html
2. https://filesignatures.net/index.php?page=search
3. https://en.wikipedia.org/wiki/List_of_file_signatures
4. https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types


## Array to store weak references
https://marcosantadev.com/swift-arrays-holding-elements-weak-references/

## About HTTP status code
https://www.w3.org/Protocols/HTTP/HTRESP.html

## Try different color combinations
http://colorsafe.co/


Tools used
Design - https://vectr.com/


