Pod::Spec.new do |s|
    s.name             = "Flagger"
    s.version          = "3.0.0"
    s.summary          = "Flagger in Swift."
    s.swift_version    = "5.1"
    s.swift_versions   = ["4.2", "5.0", "5.1"]
  
    s.description      = <<-DESC
                        A Swift framework for Flagger.
                       DESC
  
    s.homepage         = "https://github.com/jeronimo13/flagger-sdks/wrap/mobile/ios/"
    s.license          = 'MIT'
    s.author           = { "Herman Havrysh" => "gavrishgerman@gmail.com" }
    s.source           = { :git => "https://github.com/jeronimo13/flagger-sdks.git", :tag => s.version.to_s}
    s.social_media_url   = "http://twitter.com/gavrishgerman"
  
    s.ios.deployment_target = '10.0'
    #s.tvos.deployment_target = '9.0'
    #s.watchos.deployment_target = '3.0'
    #s.osx.deployment_target = '10.9'
    s.requires_arc = true
  
    s.source_files = 'Flagger/*.{swift,h}'
    s.static_framework = true
    s.vendored_frameworks = 'FlaggerGoWrapper.framework'
    
  end
  