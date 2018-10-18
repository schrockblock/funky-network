#
# Be sure to run `pod lib lint FunkyNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FunkyNetwork'
  s.version          = '0.1.10'
  s.summary          = 'FunkyNetwork provides a foundation for reusable functional networking in Swift.'

  s.description      = <<-DESC
FunkyNetwork provides a foundation for reusable functional networking in Swift. It harnesses inheritance to make adding new capabilities to a simple set of networking classes easy and fast, while pushing side effects to the boundaries of the implementation.
                       DESC

  s.homepage         = 'https://github.com/schrockblock/funky-network'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Elliot' => '' }
  s.source           = { :git => 'https://github.com/schrockblock/funky-network.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/elliot_schrock'

  s.ios.deployment_target = '8.0'

  s.source_files = 'FunkyNetwork/Classes/**/*'

  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'ReactiveSwift'
  s.dependency 'OHHTTPStubs/Swift'
  s.dependency 'Prelude', '~> 3.0'
end
