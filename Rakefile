$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'rake'
require 'graham/rake_task'

Graham::RakeTask.new
task default: :test

task :gem do
  sh "gem i #{`gem b graham.gemspec`.split("\n").last.split(/ /).last}"
end

