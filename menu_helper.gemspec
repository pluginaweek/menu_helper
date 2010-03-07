# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{menu_helper}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Pfeifer"]
  s.date = %q{2010-03-07}
  s.description = %q{Adds a helper method for generating a menubar in Rails}
  s.email = %q{aaron@pluginaweek.org}
  s.files = ["lib/menu_helper.rb", "lib/menu_helper", "lib/menu_helper/menu_bar.rb", "lib/menu_helper/html_element.rb", "lib/menu_helper/menu.rb", "test/unit", "test/unit/html_element_test.rb", "test/unit/menu_bar_test.rb", "test/unit/menu_test.rb", "test/app_root", "test/app_root/app", "test/app_root/app/controllers", "test/app_root/app/controllers/contact_controller.rb", "test/app_root/app/controllers/about_us_controller.rb", "test/app_root/app/controllers/home_controller.rb", "test/app_root/config", "test/app_root/config/routes.rb", "test/test_helper.rb", "test/helpers", "test/helpers/menu_helper_test.rb", "CHANGELOG.rdoc", "init.rb", "LICENSE", "Rakefile", "README.rdoc"]
  s.homepage = %q{http://www.pluginaweek.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pluginaweek}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Adds a helper method for generating a menubar in Rails}
  s.test_files = ["test/unit/html_element_test.rb", "test/unit/menu_bar_test.rb", "test/unit/menu_test.rb", "test/helpers/menu_helper_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
