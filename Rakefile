require 'rake'
task default: :test

task test: %w{ test:unit test:case }
namespace :test do
  %w{ unit case }.each do |test|
    task test do
      require_relative 'lib/graham'
      Dir["test/#{test}/**/*.rb"].each {|file| puts file.sub(/\.rb$/,''); load file}
    end
  end
end

task :gem do
  sh "gem i #{`gem b graham.gemspec`.split("\n").last.split(/ /).last}"
end

