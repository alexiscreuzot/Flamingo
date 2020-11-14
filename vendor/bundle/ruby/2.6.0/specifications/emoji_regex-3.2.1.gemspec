# -*- encoding: utf-8 -*-
# stub: emoji_regex 3.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "emoji_regex".freeze
  s.version = "3.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jessica Stokes".freeze]
  s.date = "2020-11-02"
  s.description = "A set of Ruby regular expressions for matching Unicode Emoji symbols.".freeze
  s.email = "hello@jessicastokes.net".freeze
  s.homepage = "https://github.com/ticky/ruby-emoji-regex".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.3".freeze
  s.summary = "Emoji Regex".freeze

  s.installed_by_version = "3.1.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.1.4"])
    s.add_development_dependency(%q<rake>.freeze, [">= 12.3.3"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 2.1.4"])
    s.add_dependency(%q<rake>.freeze, [">= 12.3.3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
  end
end
