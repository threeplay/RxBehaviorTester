Pod::Spec.new do |s|
  s.name             = 'RxBehaviorTester'
  s.version          = '0.1.0'
  s.summary          = 'Rx chains behavior testing'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  RxBehavior Tester helps with testing Rx chains that have complex behavior by
  creating matchers that describe the expected behavior of chain
                       DESC

  s.homepage         = 'https://github.com/threeplay/RxBehaviorTester'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eliran Ben-Ezra' => 'eliran@threeplay.com' }
  s.source           = { :git => 'https://github.com/threeplay/RxBehaviorTester.git', :tag => s.version.to_s }

  s.swift_version = "4.2"
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'
  s.platform = 'ios'
  s.dependency 'RxSwift', '~> 4.0'
  s.dependency 'RxBlocking', '~> 4.0'

  s.source_files = 'RxBehaviorTester/Classes/**/*'
end
