require 'graham'
class Graham::RakeTask
  include Rake::DSL
  def initialize(opts = {})
    @dir    = opts[:dir]    || :test
    @ignore = opts[:ignore] || []
    @name   = opts[:name]   || @dir
    make_task
  end

  def make_task
    tests = []
    namespace @name do
      namespace :timed do
        task :start do
          @start = Time.now
        end
        task :stop do
          puts "Tests completed after #{Time.now - @start} seconds."
        end
      end
      task timed: [ "#{@name}:timed:start", @name, "#{@name}:timed:stop" ]
      test_groups.each do |group|
        tests << name = group.sub(/\//,?:).sub(@dir.to_s,@name.to_s)
        task name.sub(/^#{@name}:/,'') do
          Dir["#{group}/*.rb"].each do |file|
            puts "\x1b[4m        #{file.sub(/\.rb$/,'')}\x1b[0m"
            load file
          end
        end
      end
    end
    task @name => tests
  end

  def test_groups
    ignore = [*@ignore].map {|d| %r|^#{@dir}/#{d}|}
    FileList["#{@dir}/**/*"].select {|f| File.directory? f}
      .reject {|d| ignore.any? {|i| d=~i}}
  end
end

