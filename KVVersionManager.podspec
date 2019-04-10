#
# Be sure to run `pod lib lint KVVersionManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KVVersionManager'
  s.version          = '0.2.7'
  s.summary          = 'a library use for KVManager app to check update version and warning user'

  s.description      = <<-DESC
  A Library that help check current version with Appstore version with both automatic and manual way
  Use with KVManager app!
                       DESC

  s.homepage         = 'https://github.com/tuantmdev/KVVersionManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'thangpham26394' => 'thang.pd@citigo.com.vn' }
  s.source           = { :git => 'https://github.com/tuantmdev/KVVersionManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'KVVersionManager/*.{h,m}'
  s.resources    = 'KVVersionManager/iVersion.bundle'
  s.dependency 'iVersion'
end
