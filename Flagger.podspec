Pod::Spec.new do |s|
    s.name             = "Flagger"
    s.version          = "3.0.1"
    s.summary          = "An open source Swift SDK for feature flagging (feature gating, feature toggles)"
    s.swift_version    = "5.1"
    s.swift_versions   = ["4.2", "5.0", "5.1"]
  
    s.description      = <<-DESC
                        An open source Swift SDK for feature flagging (feature gating, feature toggles).
                        Documentation available at https://docs.airdeploy.io
                       DESC
  
    s.homepage         = "https://airdeploy.io"
    s.license          = 'MIT'
    s.author           = { "Engineering" => "engineering@airdeploy.io" }
    s.source           = { :git => "https://github.com/airdeploy/flagger-ios.git", :tag => s.version.to_s}

    s.ios.deployment_target = '10.0'
    s.requires_arc = true
  
    s.source_files = 'Flagger/*.{swift,h}'
    s.static_framework = true
    s.vendored_frameworks = "FlaggerGoWrapper.framework"

    s.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
    s.user_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }

  end
  