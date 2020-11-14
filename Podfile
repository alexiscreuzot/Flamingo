platform :ios, '11.0'
inhibit_all_warnings!
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'

def shared_pods

    # Architecture
    pod 'PluggableAppDelegate'
    pod 'R.swift'

    # Data
    pod 'HNScraper', :git => 'https://github.com/weiran/HNScraper'
    pod 'Moya'
    pod 'ModelMapper'
    pod 'RealmSwift'
    pod 'ReadabilityKit'

    # Components
    pod 'SDWebImage'
    pod 'HTMLString'
    pod 'Attributed'
    pod 'SVProgressHUD'
    pod 'TTTAttributedLabel'

end

target 'Flamingo' do
    shared_pods
end

post_install do |installer|

    # ------------
    # Set minimal deployment target
    puts '-> Determining pod project minimal deployment target'
    pods_project = installer.pods_project
    deployment_target_key = 'IPHONEOS_DEPLOYMENT_TARGET'
    deployment_targets = pods_project.build_configurations.map{ |config| config.build_settings[deployment_target_key] }
    minimal_deployment_target = deployment_targets.min_by{ |version| Gem::Version.new(version) }
    puts 'Setting each pod deployment target to : ' + minimal_deployment_target

    # ------------
    # Apply specific build settings
    puts "-> Post install changes"
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings[deployment_target_key] = minimal_deployment_target
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
        end
    end
end