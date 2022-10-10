require 'everythingop'

require 'bundler/gem_tasks'
begin
  require 'rspec/core/rake_task'
rescue LoadError => e
  puts e.message
end

begin
  RSpec::Core::RakeTask.new(:spec)
rescue NameError, LoadError => e
  puts e.message
end

begin
  require 'rubocop/rake_task'
rescue LoadError => e
  puts e.message
end

begin
  RuboCop::RakeTask.new
rescue NameError, LoadError => e
  puts e.message
end

begin
  require 'arxutils_sqlite3/rake_task'
rescue LoadError => e
  puts e.message
end

desc 'Everythingop related operaion'
task default: %i[spec rubocop]

desc 'setting.yml'
task :everythingops do
  sh 'bundle exec exe/everythingop --cmd=s'
end
