# -*- encoding: utf-8 -*-
# stub: google-cloud-errors 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "google-cloud-errors".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mike Moore".freeze, "Chris Smith".freeze]
  s.date = "2020-01-09"
  s.description = "google-cloud-errors defines error classes for google-cloud-ruby.".freeze
  s.email = ["mike@blowmage.com".freeze, "quartzmo@gmail.com".freeze]
  s.homepage = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-errors".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4".freeze)
  s.rubygems_version = "3.1.3".freeze
  s.summary = "Error classes for google-cloud-ruby".freeze

  s.installed_by_version = "3.1.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<autotest-suffix>.freeze, ["~> 1.1"])
    s.add_development_dependency(%q<google-style>.freeze, ["~> 1.24.0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.10"])
    s.add_development_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
    s.add_development_dependency(%q<minitest-rg>.freeze, ["~> 5.2"])
    s.add_development_dependency(%q<redcarpet>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.9"])
    s.add_development_dependency(%q<yard>.freeze, ["~> 0.9"])
    s.add_development_dependency(%q<yard-doctest>.freeze, ["~> 0.1.13"])
  else
    s.add_dependency(%q<autotest-suffix>.freeze, ["~> 1.1"])
    s.add_dependency(%q<google-style>.freeze, ["~> 1.24.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.10"])
    s.add_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
    s.add_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
    s.add_dependency(%q<minitest-rg>.freeze, ["~> 5.2"])
    s.add_dependency(%q<redcarpet>.freeze, ["~> 3.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.9"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.9"])
    s.add_dependency(%q<yard-doctest>.freeze, ["~> 0.1.13"])
  end
end
