# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :bundler do
  watch("Gemfile")
end

guard :spork, :rspec_env => { 'RAILS_ENV' => 'test', 'RACK_ENV' => 'test' } do
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch(%r{spec/support/}) { :spork }
end

guard :rspec, cli: "--drb --color --fail-fast" do
  watch(%r{^app/models/(.+)\.rb$})  { |m| "spec/models/#{m[1]}_spec.rb" }
  watch(%r{^app/workers/(.+)\.rb$}) { "spec" }
  watch(%r{^lib/(.+)\.rb$})         { |m| "spec/models/silo_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')      { "spec" }
end


