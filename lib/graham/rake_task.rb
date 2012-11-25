require 'graham'
class Graham::RakeTask
  include Rake::DSL
  def initialize(opts = {})
    @dir    = opts[:dir]    || 'test'
    @ignore = opts[:ignore] || []
    make_task
  end

  def make_task
    tests = []
    namespace :test do
      namespace :timed do
        task :start do
          @start = Time.now
        end
        task :stop do
          puts "Tests completed after #{Time.now - @start} seconds."
        end
      end
      task timed: %w{ test:timed:start test test:timed:stop }
      test_groups.each do |group|
        tests << name = group.sub(/\//,?:)
        task name.sub(/^#{@dir}:/,'') do
          Dir["#{group}/*.rb"].each do |test_file|
            puts "\x1b[4m        #{test_file.sub(/\.rb$/,'')}\x1b[0m"
            load test_file
          end
        end
      end
    end
    task test: tests
  end

  def test_groups
    ignore = [*@ignore].map {|d| %r|^#{@dir}/#{d}|}
    FileList["#{@dir}/**/*"].select {|f| File.directory? f}
      .reject {|d| ignore.any? {|i| d=~i}}
  end
end

