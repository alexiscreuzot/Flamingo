# -*- encoding: utf-8 -*-
# stub: cocoapods-stats 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "cocoapods-stats".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Orta Therox".freeze, "Samuel Giddins".freeze]
  s.date = "2019-01-24"
  s.description = "Uploads statistics for Pod Analytics.".freeze
  s.email = ["orta.therox@gmail.com".freeze, "segiddins@segiddins.me".freeze]
  s.homepage = "https://github.com/cocoapods/cocoapods-stats".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.3".freeze
  s.summary = "Uploads installation version data to stats.cocoapods.org to provide per-Pod analytics.".freeze

  s.installed_by_version = "3.1.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
