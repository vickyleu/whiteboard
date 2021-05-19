#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint whiteboard.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'whiteboard'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project for tencent whiteboard.'
  s.description      = <<-DESC
A new Flutter plugin project for tencent whiteboard.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.dependency = 'TEduBoard_iOS', :podspec => 'https://sdk.qcloudtiw.com/ios/spec/TEduBoard_iOS.podspec'
  s.dependency 'TIWLogger_iOS','1.0.1.21'
  s.dependency 'TXIMSDK_iOS','4.6.101'
  s.dependency 'TXLiteAVSDK_TRTC','8.3.9884'
  # s.prepare_command = './prepare-map.sh'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
