require 'graham'
class Graham::RakeTask
  include Rake::DSL
  def initialize; task! end
  def task!
    tests = []
    namespace :test do
      test_groups.each do |group|
        tests << name = group.sub(/\//,?:)
        task name.sub(/^test:/,'') do
          Dir["#{group}/*.rb"].each do |test_file|
            puts "\x1b[4m        #{test_file.sub(/\.rb$/,'')}\x1b[0m"
            load test_file
          end
        end
      end
    end
    task test: tests
  end
  def test_groups; FileList['test/**/*'].select {|f| File.directory? f} end
end

