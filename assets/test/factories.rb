Factory.sequence(:email) {|n| "none#{n}@example.com" }
Factory.sequence(:url)   {|n| "http://www.google.com/search?client=safari&q=foo#{n}" }

Factory.define :user do |f|
  f.name "Bob"
  f.email { Factory.next(:email) }
  f.password "changeme"
  f.password_confirmation {|user| user.password }
  # This stops authlogic from logging this new user in.
  f.skip_session_maintenance true
  f.job_title "Chief Marketing Officer"
  f.company_name "ACME, Inc."
  f.user_type User::Journalist
end

Factory.define :journalist, :parent => :user do |f|
  f.user_type User::Journalist
end

Factory.define :company_representative, :parent => :user do |f|
  f.user_type User::CompanyRepresentative
end

Factory.define :administrator, :parent => :user do |f|
  f.user_type User::Administrator
end

Factory.define :page do |f|
  f.url { Factory.next(:url) }
end

Factory.define :note do |f|
  f.title "This is a note."
  f.body "This is the note body.\nBlah blah blah."
  f.association :page
  f.association :owner, :factory => :journalist
  f.note_type Note::Comment
end

Factory.define :counterpoint do |f|
  f.body "This is the counterpoint body.\nBlah blah blah."
  f.association :note
  f.association :owner, :factory => :user
end
