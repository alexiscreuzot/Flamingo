platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'

def shared_pods

    # Util
    pod 'R.swift'
    pod 'SDWebImage'
    pod 'HTMLString'
    pod 'Attributed'
    pod 'SVProgressHUD'

    # Networking
    pod 'HNScraper', :git => 'https://github.com/weiran/HNScraper'
    pod 'Moya'
    pod 'ModelMapper'
    pod 'RealmSwift'

    # Components
    pod 'TTTAttributedLabel'
    pod 'ReadabilityKit'

end

target 'Flamingo' do
    shared_pods
end

post_install do |installer|
    # puts "-> Post install changes"
    # installer.pods_project.targets.each do |target|
    #     target.build_configurations.each do |config|
    #         if ['HNScraper'].include? target.name
    #             config.build_settings['SWIFT_VERSION'] =  '4.0'
    #             config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
    #         end
    #     end
    # end
    # puts "-> Done"
end