Pod::Spec.new do |s|
  s.name         = "AURefreshControl"
  s.version      = "0.1.0"
  s.summary      = "A short description of AURefreshControl."
  s.description  = <<-DESC
                    An optional longer description of AURefreshControl

                    * Markdown format.
                    * Don't worry about the indent, we strip it!
                   DESC
  s.homepage     = "http://EXAMPLE/NAME"
  s.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license      = 'MIT'
  s.author       = { "emil.wojtaszek" => "emil.wojtaszek@gmail.com" }
  s.source       = { :git => "http://EXAMPLE/NAME.git", :tag => s.version.to_s }

  s.requires_arc = true
  s.source_files = 'Classes/*'
end
