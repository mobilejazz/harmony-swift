#
# Be sure to run `pod lib lint Harmony.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'Harmony'
    s.version          = '1.1.5'
    s.summary          = 'Mobile Jazz Harmony Core'
    s.swift_version    = '5'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    Mobile Jazz Harmony Core Repository
    DESC
    
    s.homepage         = 'https://github.com/mobilejazz/harmony-ios'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author           = { 'Mobile Jazz' => 'info@mobilejazz.com' }
    s.source           = { :git => 'https://github.com/mobilejazz/harmony-ios.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/mobilejazzcom'
    
    s.default_subspecs = 'Repository', 'Common', 'Security'
    
    s.osx.deployment_target = '10.12'
    s.ios.deployment_target = '9.0'
    
    s.source_files = 'Harmony/Harmony.h'
    
    s.subspec 'Future' do |sp|
        sp.source_files = 'Harmony/Classes/Future/**/*', 'Harmony/Harmony.h'
    end
    
    s.subspec 'Repository' do |sp|
        sp.source_files = 'Harmony/Classes/Repository/**/*', 'Harmony/Harmony.h'
        sp.dependency 'Harmony/Future'
        sp.dependency 'Harmony/Common'
    end
    
    s.subspec 'Common' do |sp|
        sp.source_files = 'Harmony/Classes/Common/**/*', 'Harmony/Harmony.h'
        sp.dependency 'Harmony/Future'
    end
    
    s.subspec 'Security' do |sp|
        sp.source_files = 'Harmony/Classes/Security/**/*', 'Harmony/Harmony.h'
        sp.frameworks = 'Security'
        sp.dependency 'Harmony/Repository'
    end
    
    s.subspec 'Alamofire' do |sp|
        sp.source_files = 'Harmony/Classes/Alamofire/**/*', 'Harmony/Harmony.h'
        sp.dependency 'Alamofire', '~> 4.8.2'
        sp.dependency 'Harmony/Future'
        sp.dependency 'Harmony/Common'
    end
    
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Realm susbspec removed as it is no longer maintained by Mobile Jazz #
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    
    #s.subspec 'Realm' do |sp|
    #    sp.source_files = 'Harmony/Classes/Realm/**/*', 'Harmony/Harmony.h'
    #    sp.dependency 'RealmSwift', '~> 3.14'
    #    sp.dependency 'Harmony/Repository'
    #    sp.dependency 'Harmony/Security'
    #end
    
    s.subspec 'iOS' do |sp|
        sp.osx.source_files = 'Harmony/Classes/iOS/readme-macOS.swift', 'Harmony/Harmony.h'
        sp.ios.source_files = 'Harmony/Classes/iOS/**/*', 'Harmony/Harmony.h'
        sp.ios.frameworks = 'UIKit'
        sp.ios.dependency 'Harmony/Common'
    end
    
    s.subspec 'Vastra' do |sp|
        sp.source_files = 'Harmony/Classes/Vastra/**/*', 'Harmony/Harmony.h'
    end
    
    s.subspec 'MJCocoaCore' do |sp|
        sp.source_files = 'Harmony/Classes/MJCocoaCore/**/*', 'Harmony/Harmony.h'
        sp.dependency 'MJCocoaCore/Common', '~> 2.3'
        sp.dependency 'Harmony/Common'
    end
    
    s.subspec 'Objection' do |sp|
        sp.source_files = 'Harmony/Classes/Objection/**/*', 'Harmony/Harmony.h'
        sp.dependency 'MJObjection'
    end
    
    s.subspec 'Testing' do |sp|
        sp.source_files = 'Harmony/Classes/Testing/**/*', 'Harmony/Harmony.h'
        sp.dependency 'Harmony/Repository'
    end
    
    # s.resource_bundles = {
    #   'Harmony' => ['Harmony/Assets/*.png']
    # }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    # s.dependency 'AFNetworking', '~> 2.3'
end
