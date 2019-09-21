# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'XNLogger' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for XNLogger

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
#  pod 'XNLogger', :path => './'

end
