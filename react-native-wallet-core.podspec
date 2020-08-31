require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-wallet-core"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "11.0" }
  s.source       = { :git => "https://github.com/Liamandrew/react-native-wallet-core.git", :tag => "#{s.version}" }
  s.swift_version = "5.0"

  s.source_files = "ios/**/*.{h,m,mm,swift}"

  s.dependency "React"
  s.dependency "TrustWalletCore", "2.1.1"
end
