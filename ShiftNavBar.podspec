Pod::Spec.new do |s|
  s.name         = "ShiftNavBar"
  s.version      = "0.1.0"
  s.summary      = "ShiftNavBar."
  s.description  = <<-DESC
                       A ShiftNavigationController
                   DESC

  s.homepage     = "https://github.com/silence0201/ShiftNavigation"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Silence" => "374619540@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/silence0201/ShiftNavigation.git", :tag => "0.1.0" }
  s.source_files  = "ShiftNavigationController", "Classes/**/*.{h,m}"
  s.exclude_files = "ShiftNavigationController/Exclude"
  s.requires_arc = true

end
