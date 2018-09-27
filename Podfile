platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'

def shared_pods

    # Util
    pod 'R.swift', '~> 4.0'
    pod 'SDWebImage', '~> 4.2'
    pod 'HTMLString', '~> 4.0'
    pod 'Attributed', '~> 4.0'
    pod 'SVProgressHUD'

    # Networking
    pod 'HNScraper', '~> 0.1.1'
    pod 'Moya', '~> 9.0.0'
    pod 'ModelMapper', '~> 7.4'
    pod 'RealmSwift'

    # Components
    pod 'TTTAttributedLabel', '~> 2.0'

end

target 'Flamingo' do
    shared_pods
end

post_install do |installer|
    puts "-> Post install changes"
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] =  '4.0'
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
        end
    end
    puts "-> Done"
end