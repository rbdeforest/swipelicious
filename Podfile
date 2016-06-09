# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'swipelicious' do
use_frameworks!

pod 'Mixpanel'
pod 'Alamofire', '~> 3.0'
pod 'HanekeSwift'
pod 'VICMAImageView', '~> 1.0'

end

post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end