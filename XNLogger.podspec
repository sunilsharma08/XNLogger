Pod::Spec.new do |s|

  s.name         = "XNLogger"
  s.version      = "1.0.1"
  s.summary      = "Framework to log network request and response."
  s.description  = <<-DESC 
  Simple and extensible network traffic logger. It makes easy log network request and response or debug network issues.
                   DESC

  s.homepage     = "https://github.com/sunilsharma08/XNLogger"
  s.screenshots  = "https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/LogListScreen.png", "https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/LogDetailsRequestScreen.png", "https://raw.githubusercontent.com/sunilsharma08/XNLogger/master/XNLoggerExample/ExampleAppScreenshots/LogDetailsResponseScreen.png"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Sunil Sharma" => "sunilsharma.ss08@gmail.com" }
  s.social_media_url   = "https://twitter.com/sunil5309"

  s.platform     = :ios
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/sunilsharma08/XNLogger.git", :tag => "v#{s.version}" }

  s.source_files  = "XNLogger/**/*.{swift,h,m}"
  s.resources = "XNLogger/UI/**/*.{xcassets,storyboard,xib}"

  s.requires_arc = true

end
