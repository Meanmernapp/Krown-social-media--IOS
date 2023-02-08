# Uncomment this line to define a global platform for your project


platform :ios, '14.0'

plugin 'cocoapods-acknowledgements', :settings_bundle => true


target 'Krown' do
  pod 'Alamofire'
  pod 'AlamofireImage'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  pod 'Flurry-iOS-SDK/FlurrySDK'
  #pod 'SwiftLocation/Core'
  pod 'SwiftLocation/Core' , :git => 'git@github.com:teglgaard/SwiftLocation.git' #This has one difference -> logging disabled. and added from another repo as well.
  pod 'XMPPFramework', :inhibit_warnings => true, :git => 'git@github.com:robbiehanson/XMPPFramework.git' #This has one difference -> 4.1.1 instead of 4.0.0
  pod 'MessageKit'
  pod 'InputBarAccessoryView'
  pod 'ImageSlideshow'
  pod 'Koloda' , :git => 'git@github.com:Teglgaard/Koloda.git' # Remember to sync if updates. It contains removal of pop animator.
  pod 'MBProgressHUD'
  pod 'Branch', :inhibit_warnings => true
  pod 'UXCam'
  pod 'KYCircularProgress'
  pod 'IQKeyboardManagerSwift'
  pod 'SwiftLint'
  pod 'SwiftEntryKit'
  pod 'RangeSeekSlider'
  #pod 'PinpointKit' #removed on 29/11/2020 after consultation with Anders
  pod 'Agrume'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Firebase/DynamicLinks'
  pod 'Siren'
  pod 'AcknowList'
  pod 'Introspect'
  pod 'SDWebImageSwiftUI'
  pod 'Cache'
  pod 'Mapbox-iOS-SDK', '~> 4.11.2'
  
  #Debug frameworks
  pod 'Wormholy', :configurations => ['Debug']
  pod "HyperioniOS/Core", :configurations => ['Debug']
  pod 'HyperioniOS/AttributesInspector', :configurations => ['Debug']
  pod 'HyperioniOS/Measurements', :configurations => ['Debug']
  pod 'HyperioniOS/SlowAnimations', :configurations => ['Debug']
  
  
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  
end
deployment_target = '14.0'#https://dtopalov.com/2020/09/18/xcode-12-and-cocoapods/

post_install do |installer|
  
  installer.pods_project.targets.each do |target|
   target.build_configurations.each do |config|
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
   end
  end
  
  
  #https://dtopalov.com/2020/09/18/xcode-12-and-cocoapods/
  installer.generated_projects.each do |project|
    project.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
      #Setting below is for ios 14 Beta version. Cocoapods will be updated where this is probably not needed.
      config.build_settings["DEVELOPMENT_TEAM"] = "3CQ45DAE98"
    end
  end
end
