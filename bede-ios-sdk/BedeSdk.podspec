Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name         = "BedeSdk"
  spec.version      = "1.0.0"
  spec.summary      = "iOS SDK for Bede Payment Gateway integration."

  spec.description  = <<-DESC
    The Bede iOS SDK provides a seamless integration with the Bede Payment Gateway.
    It supports multiple payment methods including KNET, AMEX, Credit Cards, Bookeey, and Apple Pay.
    The SDK handles payment requests, payment method retrieval, and transaction management.
  DESC

  spec.homepage     = "https://github.com/BEDE-KUWAIT"
  spec.license      = { :type => "Apache License, Version 2.0", :file => "bede-ios-sdk/LICENSE" }
  spec.authors      = {
    "Anas" => "a.qasem@pixilapps.com",
    "Hassaan" => "h.saeed@pixilapps.com"
  }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.platform     = :ios
  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source       = { :git => "https://github.com/BEDE-KUWAIT/IOS-Native.git", :tag => "#{spec.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source_files  = "IOS-Native/bede-ios-sdk/**/*.swift"
  spec.exclude_files = "IOS-Native/bede-ios-sdk/**/*.docc/**"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # No resources needed for this SDK

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.frameworks = "Foundation", "UIKit", "CryptoKit"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.requires_arc = true

end
