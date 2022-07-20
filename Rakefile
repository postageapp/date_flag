require 'rubygems'

require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests.'
task default: :test

desc 'Test the date_flag plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

require 'jeweler'

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "date_flag"
  gem.summary = %Q{Date field exension for ActiveRecord}
  gem.description = %Q{Represents boolean fields as DateTime values to trigger events in the future or record when events happened in the past.}
  gem.email = 'tadman@postageapp.com'
  gem.homepage = "https://github.com/postageapp/date_flag"
  gem.authors = [
    "Scott Tadman <tadman@postageapp.com>"
  ]
end

Jeweler::RubygemsDotOrgTasks.new
