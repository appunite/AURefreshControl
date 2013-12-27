Pod::Spec.new do |s|
  s.name         = "AURefreshControl"
  s.version      = "0.0.1"
  s.summary      = "Base class for scroll view refresh control."
  s.homepage     = "http://www.appunite.com"
  s.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license      = 'MIT'
  s.author       = { "emil.wojtaszek" => "emil.wojtaszek@gmail.com" }
  s.source       = { :git => "https://github.com/emilwojtaszek/AURefreshControl.git", :tag => s.version.to_s }

  s.requires_arc = true
  s.source_files = 'Classes/*'
end
