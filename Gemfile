source 'https://rubygems.org'

gemspec

ruby RUBY_VERSION

group :development do
  gem 'aruba'
  gem 'cucumber'
  gem 'factory_bot'
  gem 'kramdown'
  gem 'kramdown-parser-gfm'
  gem 'rake'
  gem 'rspec'
  gem 'rspec-benchmark'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'simplecov'
  gem 'yard'

  platforms :mri do
    gem 'redcarpet'
  end
end

group :debugging do
  gem 'pry'
  platforms :mri do
    gem 'pry-byebug'
  end
end
