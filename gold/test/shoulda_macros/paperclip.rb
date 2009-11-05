class Test::Unit::TestCase
  def self.should_have_paperclip_field(name, opts = {})
    klass = self.name.gsub(/Test$/, '').constantize    
    ["#{name}_file_name", "#{name}_content_type"].each do |field|
      should "have #{field} field for paperclip" do
        cols = klass.columns.select {|c| c.name == field}
        assert !cols.empty?, "#{klass} does not have a field named #{field}."
        col = cols.first
        assert_equal :string, col.type, "#{klass}.#{field} is not a string."
      end
    end
      
    should "have attachments[#{name}] via paperclip" do
      assert attachments = klass.inheritable_attributes[:attachment_definitions], 
             "#{klass} doesn't have the attachments hash."
      assert attachments[name], "#{klass} doesn't have an attachment named #{name}"
    end
    
    opts.each do |k, v|
      should "have paperclip option #{k.inspect} => #{v.inspect}" do
        h = klass.instance_variable_get("@attachments")[name] rescue {}
        assert h[k], "I don't think paperclip understands the #{k.inspect} parameter."
        assert_equal v, h[k], "#{k} wasn't set to what you expected."
      end
    end
  end
  
  # def self.should_have_attached_file name
  #   klass   = self.name.gsub(/Test$/, '').constantize
  #   matcher = have_attached_file name
  #   should matcher.description do
  #     assert_accepts(matcher, klass)
  #   end
  # end
  # 
  # def self.should_have_paperclip_field(name, opts = {})
  #   klass = self.name.gsub(/Test$/, '').constantize    
  #   ["#{name}_file_name", "#{name}_content_type"].each do |field|
  #     should "have #{field} field for paperclip" do
  #       cols = klass.columns.select {|c| c.name == field}
  #       assert !cols.empty?, "#{klass} does not have a field named #{field}."
  #       col = cols.first
  #       assert_equal :string, col.type, "#{klass}.#{field} is not a string."
  #     end
  #   end

  #   should_have_attached_file name
  #     
  #   # opts.each do |k, v|
  #   #   should "have paperclip option #{k.inspect} => #{v.inspect}" do
  #   #     h = klass.instance_variable_get("@attachments")[name] rescue {}
  #   #     assert h[k], "I don't think paperclip understands the #{k.inspect} parameter."
  #   #     assert_equal v, h[k], "#{k} wasn't set to what you expected."
  #   #   end
  #   # end
  # end

  def self.stub_all_s3_for_paperclip_model(klass)
    attachment_definitions = klass.read_inheritable_attribute(:attachment_definitions)
    attachment_definitions.each do |attachment_name, definition|
      next unless definition[:storage].to_s == "s3"

      path = "http://s3.amazonaws.com/#{definition[:bucket]}/#{definition[:path]}"

      regexp = Regexp.escape(path)
      regexp.gsub!(/:attachment/,   attachment_name.to_s.underscore.pluralize)
      regexp.gsub!(/:class/,        klass.name.tableize)

      if definition[:styles]
        styles = definition[:styles].keys.map(&:to_s) + ["original"]
        regexp.gsub!(/:style/, "(#{styles.join('|')})")
      end
      regexp.gsub!(/:id/,           '\d+')
      regexp.gsub!(/:id_partition/, '\d+\/\d+\/\d+')
      regexp.gsub!(/:rails_env/,    Rails.env)
      regexp.gsub!(/:rails_root/,   Rails.root)
      regexp.gsub!(/:[^\/]+/,      '[^\/]+')
      FakeWeb.register_uri(:any, Regexp.new(regexp), :body => "OK")
    end
  end
end

