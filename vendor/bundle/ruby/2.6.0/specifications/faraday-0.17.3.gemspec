# -*- encoding: utf-8 -*-
# stub: faraday 0.17.3 ruby lib

Gem::Specification.new do |s|
  s.name = "faraday".freeze
  s.version = "0.17.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/lostisland/faraday/issues", "changelog_uri" => "https://github.com/lostisland/faraday/blob/master/CHANGELOG.md", "homepage_uri" => "https://lostisland.github.io/faraday", "source_code_uri" => "https://github.com/lostisland/faraday/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["@technoweenie".freeze, "@iMacTia".freeze, "@olleolleolle".freeze]
  s.date = "2019-12-31"
  s.email = "technoweenie@gmail.com".freeze
  s.homepage = "https://lostisland.github.io/faraday".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9".freeze)
  s.rubygems_version = "3.1.3".freeze
  s.summary = "HTTP/REST API client library.".freeze

  s.installed_by_version = "3.1.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<multipart-post>.freeze, [">= 1.2", "< 3"])
  else
    s.add_dependency(%q<multipart-post>.freeze, [">= 1.2", "< 3"])
  end
end
