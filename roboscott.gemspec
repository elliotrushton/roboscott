Gem::Specification.new do |s|
  s.name        = 'roboscott'
  s.version     = '0.0.1'
  s.date        = '2017-11-20'
  s.summary     = 'Simple secret linter'
  s.description = 'Check if YAML files contain secrets that should be in ENV'
  s.homepage    = 'https://github.com/elliotrushton/roboscott'
  s.authors     = ['Elliot Rushton']
  s.email       = 'elliot.rushton@gmail.com'
  s.files       = ['lib/roboscott.rb', 'bin/roboscott']
  s.executables << 'roboscott'
  s.license     = 'MIT'
end
