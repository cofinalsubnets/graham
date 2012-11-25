require 'graham'
# Rake task generator for Graham. Usage is just:
#  # in Rakefile
#  require 'graham/rake_task'
#  Graham::RakeTask.new( options )
# Options (all optional) are:
# :dir:: The directory (relative to the Rakefile) where Graham should look for
#        tests. Default is 'test'
# :name:: The namespace for generated Rake tasks. Default is 'test'
# :ignore:: Directories under the test directory that will be ignored for the
#           purpose of generating namespaced Rake tasks.
# Let _name_ be the chosen namespace for tests. Then this will
# 1. Create the task _name_:_folder_ for each subfolder _folder_ under the
#    testing directory, which (non-recursively) loads each file in _folder_;
# 2. Create the task _name_, which pulls in all tasks created by (1);
# 3. For each task _t_ created by (1) and (2), create the task _t_:timed that 
#    outputs the running time of _t_ once it finishes.
#
class Graham::RakeTask
  include Rake::DSL
  def initialize(opts = {})
    @dir    = opts[:dir]    || :test
    @ignore = opts[:ignore] || []
    @name   = opts[:name]   || @dir
    make_task
  end

  private
  def make_task
    tests = []
    namespace @name do
      namespace :timed do
        task :start do
          @start = Time.now
        end
        task :stop do
          puts "Finished in #{Time.now - @start} seconds."
        end
      end
      test_groups.each do |group|
        tests << name = group.sub(/\//,?:).sub(@dir.to_s,@name.to_s)
        task name.sub(/^#{@name}:/,'') do
          Dir["#{group}/*.rb"].each do |file|
            puts "\x1b[4m        #{file.sub(/\.rb$/,'')}\x1b[0m"
            load file
          end
        end
      end
      task timed: [ "#{@name}:timed:start", @name, "#{@name}:timed:stop" ]
    end
    task @name => tests
    tests.each do |test|
      task "#{test}:timed" => [ "#{@name}:timed:start", test, "#{@name}:timed:stop" ]
    end
  end

  def test_groups
    ignore = [*@ignore].map {|d| %r|^#{@dir}/#{d}|}
    FileList["#{@dir}/**/*"].select {|f| File.directory? f}
      .reject {|d| ignore.any? {|i| d=~i}}
  end
end

