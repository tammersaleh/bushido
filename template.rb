require 'open-uri'

@app_name        = File.basename(@root)
@heroku_app_name = File.basename(@root).gsub('_', '-')
@template_root   = File.dirname(template)
@jquery_version  = "1.3.2"
@human_app_name  = @app_name.gsub(/[-_]/, ' ').humanize
@title_app_name  = @app_name.gsub(/[-_]/, ' ').titlecase

raise "The template path must be absolute." unless @template_root =~ /^(\/|http:\/\/)/

def read_asset_file(filename)
  open([@template_root, 'assets', filename].join('/')).read
end

def copy_asset_file(filename)
  file filename, read_asset_file(filename)
end

def get_value(name, question)
  value = ARGV.select {|arg| arg.starts_with?("--#{name}=")}.map {|arg| arg.split('=').second }.first
  value = ask question unless value
  instance_variable_set("@#{name}", value)
end

get_value :hoptoad_key,    "What's your hoptoad key?  GIVE IT TO ME!"
get_value :gmail_username, "What gmail username do you want to use for outgoing email?"
get_value :gmail_password, "What gmail password do you want to use for outgoing email?"
get_value :s3_key,         "What's your S3 key?"
get_value :s3_secret,      "What's your S3 secret?"

@s3_bucket = @app_name

datestring = Time.now.strftime("%j %U %w %A %B %d %Y %I %M %S %p %Z")
@session_store_key = Digest::MD5.hexdigest("#{@app_name} #{datestring}")

# Delete unnecessary files
run "rm README"
run "rm public/index.html"
run "rm public/javascripts/*"
run "rm -rf test/fixtures"

inside "public/stylesheets" do
  run "curl -L http://github.com/joshuaclayton/blueprint-css/tarball/master | tar -xzf -"
  run "mv joshuaclayton-blueprint*/blueprint blueprint"
  run "rm -rf joshuaclayton-blueprint*"
end

inside "public/javascripts" do
  run "curl -L http://jqueryjs.googlecode.com/files/jquery-#{@jquery_version}.js -o jquery-#{@jquery_version}.js"
end

plugin 'trusted-params',        :git => "git://github.com/ryanb/trusted-params.git"
plugin 'hoptoad_notifier',      :git => "git://github.com/thoughtbot/hoptoad_notifier.git"
plugin 'high_voltage',          :git => "git://github.com/thoughtbot/high_voltage.git"
plugin 'limerick_rake',         :git => "git://github.com/thoughtbot/limerick_rake.git"
plugin 'blue-ridge',            :git => "git://github.com/relevance/blue-ridge.git"
plugin 'validation_reflection', :svn => "svn://rubyforge.org//var/svn/valirefl/validation_reflection/trunk"

# Prod gems
gem 'RedCloth'
gem 'authlogic',                                                                                         :version => '>= 2.1.1'  
gem 'justinfrench-formtastic',       :lib => 'formtastic',          :source => 'http://gems.github.com', :version => '>= 0.2.2'
gem 'josevalim-inherited_resources', :lib => 'inherited_resources', :source => 'http://gems.github.com', :version => '>= 0.8.5'
gem 'thoughtbot-paperclip',          :lib => 'paperclip',           :source => 'http://gems.github.com', :version => '>= 2.3.1'
gem 'mislav-will_paginate',          :lib => 'will_paginate',       :source => 'http://gems.github.com', :version => '>= 2.3.11'
gem 'ambethia-smtp-tls',             :lib => 'smtp-tls',            :source => 'http://gems.github.com', :version => '>= 1.1.2'

# Test gems
gem 'mocha',    :env => "test"
gem 'nokogiri', :env => "test", :lib => false
gem 'webrat',   :env => "test"               
gem 'fakeweb',  :env => "test"               
gem 'thoughtbot-factory_girl', :lib => "factory_girl", :source => "http://gems.github.com", :env => "test"
gem 'thoughtbot-shoulda',      :lib => "shoulda",      :source => "http://gems.github.com", :env => "test"

generate 'blue_ridge'
generate 'formtastic_stylesheets'
run "haml --rails ."

file '.gitignore', read_asset_file('gitignore')

copy_asset_file 'app/controllers/pages_controller.rb'
copy_asset_file 'app/controllers/user_activations_controller.rb'
copy_asset_file 'app/controllers/user_sessions_controller.rb'
copy_asset_file 'app/controllers/users_controller.rb'
copy_asset_file 'app/helpers/pages_helper.rb'
copy_asset_file 'app/models/mailer.rb'
copy_asset_file 'app/models/user.rb'
copy_asset_file 'app/models/user_activation.rb'
copy_asset_file 'app/models/user_session.rb'
copy_asset_file 'app/views/layouts/_flashes.html.haml'
copy_asset_file 'app/views/mailer/reset_password_request.erb'
copy_asset_file 'app/views/mailer/user_activation.erb'
copy_asset_file 'app/views/pages/home.html.haml'
copy_asset_file 'app/views/user_activations/show.html.haml'
copy_asset_file 'app/views/user_sessions/new.html.haml'
copy_asset_file 'app/views/users/_form.html.haml'
copy_asset_file 'app/views/users/_user.html.haml'
copy_asset_file 'app/views/users/edit.html.haml'
copy_asset_file 'app/views/users/new.html.haml'
copy_asset_file 'app/views/users/show.html.haml'
copy_asset_file 'config/environments/staging.rb'
copy_asset_file 'config/initializers/action_mailer_configs.rb'
copy_asset_file 'config/initializers/bigdecimal_segfault_fix.rb'
copy_asset_file 'config/initializers/errors.rb'
copy_asset_file 'config/initializers/formtastic_config.rb'
copy_asset_file 'config/initializers/hoptoad.rb'
copy_asset_file 'config/initializers/mocks.rb'
copy_asset_file 'config/initializers/noisy_attr_accessible.rb'
copy_asset_file 'config/initializers/paperclip.rb'
copy_asset_file 'config/initializers/requires.rb'
copy_asset_file 'config/initializers/time_formats.rb'
copy_asset_file 'config/locales/en.yml'
copy_asset_file 'config/routes.rb'
copy_asset_file 'db/migrate/20090805175804_create_users.rb'
copy_asset_file 'lib/tasks/heroku_gems.rake'
copy_asset_file 'lib/tasks/paperclip_tasks.rake'
copy_asset_file 'public/images/default_medium_avatar.jpg'
copy_asset_file 'public/images/default_small_avatar.jpg'
copy_asset_file 'public/javascripts/application.js'
copy_asset_file 'public/stylesheets/screen.css'
copy_asset_file 'test/factories.rb'
copy_asset_file 'test/functional/application_controller_test.rb'
copy_asset_file 'test/functional/pages_controller_test.rb'
copy_asset_file 'test/functional/user_activations_controller_test.rb'
copy_asset_file 'test/functional/user_sessions_controller_test.rb'
copy_asset_file 'test/functional/users_controller_test.rb'
copy_asset_file 'test/integration/signup_test.rb'
copy_asset_file 'test/javascript/spec_helper.js'
copy_asset_file 'test/shoulda_macros/assert_select.rb'
copy_asset_file 'test/shoulda_macros/authlogic.rb'
copy_asset_file 'test/shoulda_macros/functionals.rb'
copy_asset_file 'test/shoulda_macros/integration.rb'
copy_asset_file 'test/shoulda_macros/named_scope.rb'
copy_asset_file 'test/shoulda_macros/pagination.rb'
copy_asset_file 'test/shoulda_macros/paperclip.rb'
copy_asset_file 'test/test_helper.rb'
copy_asset_file 'test/unit/helpers/application_helper_test.rb'
copy_asset_file 'test/unit/helpers/pages_helper_test.rb'
copy_asset_file 'test/unit/mailer_test.rb'
copy_asset_file 'test/unit/user_activation_test.rb'
copy_asset_file 'test/unit/user_session_test.rb'
copy_asset_file 'test/unit/user_test.rb'

append_file "Rakefile", read_asset_file('Rakefile.fragment')
append_file "config/environments/production.rb",  "\n\nHOST = '#{@heroku_app_name}.heroku.com'"
append_file "config/environments/staging.rb",     "\n\nHOST = '#{@heroku_app_name}-staging.heroku.com'"
append_file "config/environments/development.rb", "\n\nHOST = '#{@heroku_app_name}.local'"
append_file "config/environments/test.rb",        "\n\nHOST = 'localhost'"

gsub_file 'config/environment.rb', /(^Rails::Initializer.run\b)/mi do |match|
  read_asset_file('config/environment.rb.fragment') + match
end

gsub_file 'app/controllers/application_controller.rb', /(^end\b)/mi do |match|
  read_asset_file('app/controllers/application_controller.rb.fragment') + match
end

gsub_file 'app/helpers/application_helper.rb', /(^end\b)/mi do |match|
  read_asset_file('app/helpers/application_helper.rb.fragment') + match
end

gsub_file 'config/initializers/session_store.rb', /:secret(\s*)=> '(.*)'/ do |match|
  ":secret => ENV['SESSION_STORE_KEY']"
end

file 'app/views/layouts/application.html.haml', 
%Q|!!!
%html{ "xml:lang" => "en", :lang => "en", :xmlns => "http://www.w3.org/1999/xhtml" }
  %head
    %meta{ :content => "text/html; charset=utf-8", "http-equiv" => "Content-type" }
    %title
      #{@title_app_name}
    = stylesheet_link_tag "blueprint/screen", :media => "screen, projection"
    = stylesheet_link_tag "blueprint/print", :media => "print"
    = stylesheet_link_tag "formtastic"
    = stylesheet_link_tag "formtastic_changes"
    = stylesheet_link_tag 'screen', :media => 'all', :cache => true
  %body{ :class => body_class }
    #header
      %h1
        #{@title_app_name}
      #session_links
        - if current_user
          .welcome
            Hello,
            = link_to current_user, current_user
          .logout
            = link_to "Logout", user_session_url, :method => :delete
        - else
          .login
            = link_to "Login", login_url
          or
          .signup
            = link_to "Signup for a new account", signup_url
    #content
      = render :partial => 'layouts/flashes'
      = yield
    #footer
      &copy; 2009 Tammer Saleh Consulting, Inc.
    = render :partial => 'layouts/javascript'
|

file 'config/database.yml', 
%Q{
development:
  adapter: mysql
  database: #{@app_name}_development
  username: root
  password: 
  host: localhost
  encoding: utf8
  
test:
  adapter: mysql
  database: #{@app_name}_test
  username: root
  password: 
  host: localhost
  encoding: utf8
}

file 'app/views/layouts/_javascript.html.haml',
"= javascript_include_tag \"jquery-#{@jquery_version}\", \"application\", :cache => true
= yield :javascript"

rake 'gems:heroku_spec'

run 'find . -type d -empty -exec touch {}/.keep \;'
run 'rm log/*'

git :init
git :add => '.'
run "git commit -m 'Intial application creation using #{template}.'"

begin
  puts "Creating #{@s3_bucket} bucket in S3."
  require 'right_aws'
  RightAws::S3Interface.new(@s3_key, @s3_secret).create_bucket(@s3_bucket)
rescue
  puts "** Failed to create the #{@s3_bucket} bucket"
end

if `which heroku`.blank?
  puts "** Skipping Heroku app setup, as heroku gem not installed."
else
  if `heroku list | grep -x #{@heroku_app_name}-staging`.blank?
    out = run("heroku create #{@heroku_app_name}-staging --remote heroku-staging")
    if out =~ /^Created http/
      run "heroku config:add RACK_ENV=staging"
      run "heroku config:add HOPTOAD_KEY='#{@hoptoad_key}'"
      run "heroku config:add GMAIL_USERNAME='#{@gmail_username}'"
      run "heroku config:add GMAIL_PASSWORD='#{@gmail_password}'"
      run "heroku config:add SESSION_STORE_KEY='#{@session_store_key}'"
      run "heroku config:add S3_KEY='#{@s3_key}'"
      run "heroku config:add S3_SECRET='#{@s3_secret}'"
      run "heroku config:add S3_BUCKET='#{@s3_bucket}'"
      run "git push heroku-staging master"
      run "heroku rake db:migrate"
      run "heroku restart"
      run "heroku open"
    else
      puts "** Skipping rest of heroku configuration, as there was an error talking to Heroku:"
      puts "**   #{out}"
    end
  else
    puts "** Skipping Heroku app setup, as #{@heroku_app_name}-staging already seems to exist."
  end
end

file "config/heroku_env.rb", %Q{
# This file contains the ENV vars necessary to run the app locally.  
# Some of these values are sensitive, and some are developer specific.
#
# DO NOT CHECK THIS FILE INTO VERSION CONTROL

ENV['HOPTOAD_KEY']       = '#{@hoptoad_key}'
ENV['GMAIL_USERNAME']    = '#{@gmail_username}'
ENV['GMAIL_PASSWORD']    = '#{@gmail_password}'
ENV['SESSION_STORE_KEY'] = '#{@session_store_key}'
ENV['S3_KEY']            = '#{@s3_key}'
ENV['S3_SECRET']         = '#{@s3_secret}'
ENV['S3_BUCKET']         = '#{@s3_bucket}'
}
