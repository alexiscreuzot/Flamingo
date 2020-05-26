platform :ios, '10.0'
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