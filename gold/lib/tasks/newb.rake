desc "Configure initial environment for development"
task :newb => %w(newb:guard_env 
                 newb:heroku_gems  
                 gems:install
                 db:create:all  
                 db:migrate
                 db:seed
                 db:test:prepare  
                 test)

task "newb:heroku_gems" do
  %w(heroku taps).each do |gem|
    unless Gem.available? gem
      puts "gem install #{gem}" 
      system("gem install #{gem}")
    end
  end
end

task "newb:guard_env" do
  env = ENV["RAILS_ENV"] 
  unless env == "development" or env == nil
    raise RuntimeError, "You're not supposed to run this outside of development.  Dangerous."
  end
end
