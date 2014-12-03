Pod::Spec.new do |s|
  s.name             = "DTVTableView"
  s.version          = "0.1.0"
  s.summary          = "Table view rewrite with dynamic cell height"
  s.description      = <<-DESC
                       DTVTableView constantly recalculates row positions and the scroll view's content size while scrolling through the list.
                       DESC
  s.homepage         = "https://github.com/tomquist/DynamicTableView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Tom Quist" => "tom@quist.de" }
  s.source           = { :git => "https://github.com/tomquist/DynamicTableView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tomqueue'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'DTVTableView' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
