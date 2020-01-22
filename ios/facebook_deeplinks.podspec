#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint facebook_deeplinks.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'facebook_deeplinks'
  s.version          = '0.1.0'
  s.summary          = 'A flutter plugin to get facebook deeplinks and transferring them to the flutter application.'
  s.description      = <<-DESC
A flutter plugin to get facebook deeplinks and transferring them to the flutter application.
                       DESC
  s.homepage         = 'https://github.com/rbcprolabs/facebook_deeplinks'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ramil Zaynetdinov' => 'me@proteye.ru' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FBSDKCoreKit', '5.5.0'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
