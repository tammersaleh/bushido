require 'open-uri'

@app_name       = File.basename(@root)
@template_root  = File.dirname(template)
@jquery_version = "1.3.2"
@human_app_name = @app_name.gsub(/[-_]/, ' ').humanize
@title_app_name = @app_name.gsub(/[-_]/, ' ').titlecase

raise "The template path must be absolute." unless @template_root =~ /^(\/|http:\/\/)/

def read_asset_file(filename)
  File.open([@template_root, 'assets', filename].join('/')).read
end

def copy_asset_file(filename)
  file filename, read_asset_file(filename)
end

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

plugin 'hoptoad_notifier',      :git => "git://github.com/thoughtbot/hoptoad_notifier.git"
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

# Test gems
gem 'mocha',    :env => "test"
gem 'nokogiri', :env => "test", :lib => false
gem 'webrat',   :env => "test"               
gem 'fakeweb',  :env => "test"               
gem 'thoughtbot-factory_girl',   :lib => "factory_girl",   :source => "http://gems.github.com", :env => "test"
gem 'thoughtbot-shoulda',        :lib => "shoulda",        :source => "http://gems.github.com", :env => "test"
gem 'thoughtbot-quietbacktrace', :lib => "quietbacktrace", :source => "http://gems.github.com", :env => "test"

generate 'blue_ridge'
generate 'formtastic_stylesheets'

file '.gitignore', read_asset_file('gitignore')

numbers = %w(0 1 2 3 4 5 6 7 8 9)
alphabet = %w(a b c d e f g h i j
              k l m n o p q r s t 
              u v w x y z)
alpha_num = numbers + alphabet + alphabet.map {|c| c.upcase}

initializer 'session_store.rb', <<-END
ActionController::Base.session = { 
  :session_key => '_#{@app_name}_session', 
  :secret => '#{(1..40).map {|i| alpha_num[rand(alpha_num.size)] }.join}' 
}
END

copy_asset_file 'db/migrate/20090805175804_create_users.rb'
copy_asset_file 'app/views/layouts/_flashes.html.erb'
copy_asset_file 'app/controllers/user_sessions_controller.rb'
copy_asset_file 'app/controllers/users_controller.rb'
copy_asset_file 'app/models/user.rb'
copy_asset_file 'app/models/user_session.rb'
copy_asset_file 'app/views/users/_form.html.erb'
copy_asset_file 'app/views/users/_user.html.erb'
copy_asset_file 'app/views/users/edit.html.erb'
copy_asset_file 'app/views/users/new.html.erb'
copy_asset_file 'app/views/users/show.html.erb'
copy_asset_file 'app/views/user_sessions/new.html.erb'
copy_asset_file 'config/routes.rb'
copy_asset_file 'config/initializers/requires.rb'
copy_asset_file 'config/initializers/time_formats.rb'
copy_asset_file 'config/initializers/errors.rb'
copy_asset_file 'config/initializers/action_mailer_configs.rb'
copy_asset_file 'config/initializers/aws.rb'
copy_asset_file 'config/initializers/bigdecimal_segfault_fix.rb'
copy_asset_file 'config/initializers/formtastic_config.rb'
copy_asset_file 'config/initializers/mocks.rb'
copy_asset_file 'config/initializers/noisy_attr_accessible.rb'
copy_asset_file 'config/initializers/paperclip.rb'
copy_asset_file 'config/environments/staging.rb'
copy_asset_file 'lib/tasks/paperclip_tasks.rake'
copy_asset_file 'lib/tasks/heroku_gems.rake'
copy_asset_file 'public/images/default_medium_avatar.jpg'
copy_asset_file 'public/images/default_small_avatar.jpg'
copy_asset_file 'public/javascripts/application.js'
copy_asset_file 'public/stylesheets/screen.css'
copy_asset_file 'test/factories.rb'
copy_asset_file 'test/functional/application_controller_test.rb'
copy_asset_file 'test/functional/user_sessions_controller_test.rb'
copy_asset_file 'test/functional/users_controller_test.rb'
copy_asset_file 'test/unit/user_session_test.rb'
copy_asset_file 'test/unit/user_test.rb'
copy_asset_file 'test/unit/helpers/application_helper_test.rb'
copy_asset_file 'test/test_helper.rb'
copy_asset_file 'test/shoulda_macros/assert_select.rb'
copy_asset_file 'test/shoulda_macros/authlogic.rb'
copy_asset_file 'test/shoulda_macros/functionals.rb'
copy_asset_file 'test/shoulda_macros/integration.rb'
copy_asset_file 'test/shoulda_macros/named_scope.rb'
copy_asset_file 'test/shoulda_macros/pagination.rb'
copy_asset_file 'test/shoulda_macros/paperclip.rb'
copy_asset_file 'test/javascript/spec_helper.js'

append_file "Rakefile", read_asset_file('Rakefile.fragment')
append_file "config/environments/development.rb", "\nHOST = 'localhost'"
append_file "config/environments/test.rb", "
HOST = 'localhost'
require 'factory_girl'
begin require 'redgreen'; rescue LoadError; end
"

gsub_file 'app/controllers/application_controller.rb', /(^end\b)/mi do |match|
  read_asset_file('app/controllers/application_controller.rb.fragment') + match
end

gsub_file 'app/helpers/application_helper.rb', /(^end\b)/mi do |match|
  read_asset_file('app/helpers/application_helper.rb.fragment') + match
end

file 'app/views/layouts/application.html.erb', 
%Q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang='en' xml:lang='en' xmlns='http://www.w3.org/1999/xhtml'>
  <head>
    <meta content='text/html; charset=utf-8' http-equiv='Content-type' />
    <title>#{@title_app_name}</title>
    <%= stylesheet_link_tag "blueprint/screen", :media => "screen, projection" %>
    <%= stylesheet_link_tag "blueprint/print", :media => "print" %>
    <%= stylesheet_link_tag "formtastic" %>
    <%= stylesheet_link_tag "formtastic_changes" %>
    <%= stylesheet_link_tag 'screen', :media => 'all', :cache => true %>
  </head>
  <body class="<%= body_class %>" >
    <div id='header'>
      <h1>#{@title_app_name}</h1>
      <div id='session_links'>
        <% if current_user %>
        <div class='welcome'>
          Hello,
          <%= link_to current_user, current_user %>
        </div>
        <div class='logout'>
          <%= link_to "Logout", user_session_url, :method => :delete %>
        </div>
        <% end %>
      </div>
    </div>
    <div id='content'>
      <%= render :partial => 'layouts/flashes' %>
      <%= yield %>
    </div>
    <div id='footer'>
    </div>
    <%= render :partial => 'layouts/javascript' %>
  </body>
</html>
}

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

file 'app/views/layouts/_javascript.html.erb',
"<%= javascript_include_tag \"jquery-#{@jquery_version}\", \"application\", :cache => true %>
<%= yield :javascript %>"

rake 'gems:heroku_spec'

run 'find . -type d -empty -exec touch {}/.keep \;'
run 'rm log/*'

# git :init
# git :add => '.'
