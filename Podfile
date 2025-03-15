# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

target 'UMC-Reborn' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_modular_headers!

  # Pods for UMC-Reborn

  pod 'Alamofire'
  pod 'Tabman', '~> 3.0'
  pod 'DropDown'
  pod 'KakaoSDKCommon', ‘~> 2.11.3’
  pod 'KakaoSDKAuth', ‘~> 2.11.3’
  pod 'KakaoSDKUser', ‘~> 2.11.3’
  pod "BSImagePicker", "~> 3.1"
  pod 'RxSwift', '6.8.0'
  pod 'RxCocoa', '6.8.0'

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        config.build_settings['EXCLUDED_ARCHS[sdk=watchsimulator*]'] = 'arm64'
        config.build_settings['EXCLUDED_ARCHS[sdk=appletvsimulator*]'] = 'arm64'
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        config.build_settings['ENABLE_BITCODE'] = 'NO'
      end
    end
  end

end
