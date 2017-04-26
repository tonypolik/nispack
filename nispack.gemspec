# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nispack"

Gem::Specification.new do |s|
  s.name        = "nispack"
  s.version     = Nispack::VERSION
  s.authors     = ["tonypolik"]
  s.email       = ["tonypolik@gmail.com"]
  s.homepage    = "https://github.com/tonypolik"
  s.summary     = %q{Easy handling of NISPACK files.}
  s.description = %q{Easy handling of NISPACK files. You can extract the files or create a new archive from a directory.}

  s.rubyforge_project = "nispack"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "getopt"
end
