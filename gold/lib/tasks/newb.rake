desc "Configure initial environment for development"
task :newb => %w(newb:guard_env 
                 newb:gems  
                 db:create:all  
                 db:migrate
                 db:seed
                 db:test:prepare  
                 test)

task "newb:gems" do
  %w(heroku taps).each do |gem|
    unless Gem.available? gem
      puts "sudo gem install #{gem}" 
      system("sudo gem install #{gem}")
    end
  end

  puts "Installing system wide gems"
  out = %x{sudo rake gems:install}
  raise RuntimeError.new("Error running `sudo rake gems:install`:  #{out}") unless $? == 0
end

task "newb:guard_env" do
  env = ENV["RAILS_ENV"] 
  unless env == "development" or env == nil
    raise RuntimeError, "You're not supposed to run this outside of development.  Dangerous."
  end
end
