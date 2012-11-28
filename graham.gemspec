$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'rake'
require 'graham/version'

graham = Gem::Specification.new do |spec|
  spec.add_dependency 'mallow', '>=0.0.4'
  spec.name        = 'graham'
  spec.version     = Graham::VERSION
  spec.author      = 'feivel jellyfish'
  spec.email       = 'feivel@sdf.org'
  spec.files       = FileList['README.md','graham.gemspec', 'lib/**/*.rb']
  spec.test_files  = FileList['Rakefile','test/**/*.rb']
  spec.homepage    = 'http://github.com/gwentacle/graham'
  spec.summary     = 'Miniature test engine based on Mallow'
  spec.description = 'Miniature test engine based on Mallow'
end

