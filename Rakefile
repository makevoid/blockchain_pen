task default: :run

task :run do
  IO.popen "bundle exec guard"
  IO.popen "rackup -p 3001"
  sleep
end
