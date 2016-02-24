$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_view/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activeview"
  s.version     = ActiveView::VERSION
  s.authors     = ["Ivgeni Slabkovski"]
  s.email       = ["zhenya@zhenya.ca"]
  s.homepage    = "TODO"
  s.summary     = "A view model extention to rails to facilitate HMVC."
  s.description = "Capture the essense of MVC in its entierty by making it recursive."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'railties', "~> 4.2.5.1"
  s.add_dependency 'activesupport', "~> 4.2.5.1"
  s.add_dependency 'actionview', "~> 4.2.5.1"
  s.add_dependency 'activemodel', "~> 4.2.5.1"
  s.add_dependency 'actionpack', "~> 4.2.5.1"

  s.add_development_dependency "rails"
  s.add_development_dependency "sqlite3"
end
