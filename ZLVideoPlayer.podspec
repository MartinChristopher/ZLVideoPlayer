Pod::Spec.new do |s|
  s.name             = 'ZLVideoPlayer'
  s.version          = '0.0.1'
  s.summary          = 'A short description of ZLVideoPlayer.'
  s.homepage         = 'https://github.com/MartyChristopher/ZLVideoPlayer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { "MartyChristopher" => "519483040@qq.com" }
  s.source           = { :git => 'https://github.com/MartyChristopher/ZLVideoPlayer.git', :tag => s.version.to_s }
  
  s.requires_arc = true
  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'
  
  s.source_files = 'ZLVideoPlayer/**/*.{swift}'
  # s.resources = "ZLVideoPlayer/**/*.{bundle,strings,xcassets}"
  
  # s.dependency "RxSwift", "6.5.0"
  # s.dependency "RxCocoa", "6.5.0"
  # s.dependency "NSObject+Rx", "5.2.2"
end
