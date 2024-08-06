Pod::Spec.new do |s|

s.name                       = 'Bitmap'
s.version                    = '1.2.1'
s.summary                    = 'A Swift-y convenience for loading, saving and manipulating bitmap images.'
s.homepage                   = 'https://github.com/dagronf/Bitmap'
s.license                    = { :type => 'MIT', :file => 'LICENSE' }
s.author                     = { 'Darren Ford' => 'dford_au-reg@yahoo.com' }

s.source                     = { :git => 'https://github.com/dagronf/Bitmap.git', :tag => s.version.to_s }
s.dependency                 'SwiftImageReadWrite', '~> 1.7.1'

s.module_name                = 'Bitmap'

s.osx.deployment_target      = '10.11'
s.ios.deployment_target      = '13.0'
s.tvos.deployment_target     = '13.0'
s.watchos.deployment_target  = '6.0'

s.osx.framework              = 'AppKit'
s.ios.framework              = 'UIKit'
s.tvos.framework             = 'UIKit'
s.watchos.framework          = 'UIKit'

s.source_files               = 'Sources/Bitmap/**/*.swift'
s.resources                  = [ "Sources/Bitmap/PrivacyInfo.xcprivacy" ]

s.swift_versions             = ['5.4', '5.5', '5.6', '5.7', '5.8', '5.9', '5.10']

end
