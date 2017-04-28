require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.libs = %w[lib spec]
  t.ruby_opts << '-rubygems'
  t.warning = false
  t.test_files = FileList['spec/**/*_spec.rb']
end

task(default: %i[rubocop test])
