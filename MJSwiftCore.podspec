#
# Be sure to run `pod lib lint MJSwiftCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'MJSwiftCore'
    s.version          = '0.4.7'
    s.summary          = 'Mobile Jazz Swift toolkit utilities'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    Mobile Jazz Swift toolkit utilities for macOS and iOS.
    DESC
    
    s.homepage         = 'https://github.com/mobilejazz/MJSwiftCore'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author           = { 'Mobile Jazz' => 'info@mobilejazz.com' }
    s.source           = { :git => 'https://github.com/mobilejazz/MJSwiftCore.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/mobilejazzcom'
    
    s.default_subspecs = 'Common', 'Security'
    
    s.osx.deployment_target = '10.12'
    s.ios.deployment_target = '9.0'

    s.subspec 'Future' do |sp|
        sp.source_files = 'MJSwiftCore/Classes/Future/**/*'
    end
    
    s.subspec 'Common' do |sp|
        sp.source_files = 'MJSwiftCore/Classes/Common/**/*'
        sp.dependency 'MJSwiftCore/Future'
    end
    
    s.subspec 'Security' do |sp|
        sp.source_files = 'MJSwiftCore/Classes/Security/**/*'
        sp.frameworks = 'Security'
        sp.dependency 'MJSwiftCore/Common'
    end
    
    s.subspec 'Alamofire' do |sp|
        sp.source_files = 'MJSwiftCore/Classes/Alamofire/**/*'
        sp.dependency 'Alamofire', '~> 4.7.2'
        sp.dependency 'MJSwiftCore/Common'
    end
    
    s.subspec 'Realm' do |sp|
        sp.source_files = 'MJSwiftCore/Classes/Realm/**/*'
        sp.dependency 'RealmSwift', '~> 3.3.2'
        sp.dependency 'MJSwiftCore/Common'
        sp.dependency 'MJSwiftCore/Security'
    end
    
    s.subspec 'iOS' do |sp|
        sp.osx.source_files = 'MJSwiftCore/Classes/iOS/readme-macOS.swift'
        sp.ios.source_files = 'MJSwiftCore/Classes/iOS/**/*'
        sp.ios.frameworks = 'UIKit'
        sp.ios.dependency 'MJSwiftCore/Common'
    end
    
    s.subspec 'Vastra' do |sp|
        sp.source_files = 'MJSwiftCore/Classes/Vastra/**/*'
    end
    
    s.subspec 'MJCocoaCore' do |sp|
        sp.source_files = 'MJSwiftCore/Classes/MJCocoaCore/**/*'
        sp.dependency 'MJCocoaCore/Common', '~> 2.3.8'
        sp.dependency 'MJSwiftCore/Common'
    end
    
    s.subspec 'Objection' do |sp|
        sp.source_files = 'MJSwiftCore/Classes/Objection/**/*'
        sp.dependency 'MJObjection'
    end
    
    # s.resource_bundles = {
    #   'MJSwiftCore' => ['MJSwiftCore/Assets/*.png']
    # }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    # s.dependency 'AFNetworking', '~> 2.3'
end
