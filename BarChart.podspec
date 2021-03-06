Pod::Spec.new do |s|
  s.name             = "BarChart"
  s.summary          = "A short description of BarChart."
  s.version          = "0.1"
  s.homepage         = "https://github.com/hyperoslo/BarChart"
  s.license          = 'MIT'
  s.author           = { "Hyper Interaktiv AS" => "ios@hyper.no" }
  s.source           = { :git => "https://github.com/hyperoslo/BarChart.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hyperoslo'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Source/**/*'

#  s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Hex'
end
