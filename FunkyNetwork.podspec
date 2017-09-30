#
# Be sure to run `pod lib lint FunkyNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FunkyNetwork'
  s.version          = '0.0.3'
  s.summary          = 'FunkyNetwork provides a foundation for reusable functional networking in Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
FunkyNetwork provides a foundation for reusable functional networking in Swift.
                       DESC

  s.homepage         = 'https://github.com/schrockblock/funky-network'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Elliot' => '' }
  s.source           = { :git => 'https://github.com/schrockblock/funky-network.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/elliot_schrock'

  s.ios.deployment_target = '8.0'

  s.source_files = 'FunkyNetwork/Classes/**/*'

  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'ReactiveSwift', '~> 2.0'
  s.dependency 'OHHTTPStubs/Swift'
end
