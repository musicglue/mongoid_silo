# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :bundler do
  watch("Gemfile")
end

guard :rspec do
  watch(%r{^app/models/(.+)\.rb$}) { |m| "spec/models/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})
end