# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

def commonPods
  pod 'GzipSwift', '~> 4.1.0'
end

target 'XNLogger' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for XNLogger
  commonPods

  target 'XNLoggerTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Swifter', '~> 1.4.5'
  end

end

target 'XNLoggerExample' do
  project 'XNLoggerExample/XNLoggerExample'
  workspace 'XNLogger'
  
  use_frameworks!
  
  commonPods
end
