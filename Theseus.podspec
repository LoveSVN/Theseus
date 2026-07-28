Pod::Spec.new do |spec|
  spec.name         = "Theseus"
  spec.version      = "0.0.1"
  spec.summary      = "Backport iOS26 Liquid Glass effect"
  spec.homepage     = "https://github.com/valzevul/Theseus"
  spec.license      = "MIT"
  spec.author       = "valzevul"
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/LoveSVN/Theseus.git", :branch => "main" }
  spec.source_files = "Sources/Theseus/**/*.swift"
  spec.resources    = "Sources/Theseus/Shaders/**/*.metal"
  spec.frameworks   = "UIKit", "Metal", "MetalKit", "QuartzCore", "IOSurface"
  spec.swift_version = "5.9"
end