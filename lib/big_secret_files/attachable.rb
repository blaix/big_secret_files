require 'fileutils'

module BigSecretFiles
  module Attachable
    def has_big_secret(name)
      define_method("#{name}_dir".to_sym) do
        return nil if new_record?
        File.expand_path(RAILS_ROOT + "/data/#{ENV['RAILS_ENV']}/#{self.class.to_s.underscore}/#{id}/#{name}")
      end

      define_method("#{name}_path") do
        return nil if new_record? || !self.send("#{name}_filename?")
        dir = self.send("#{name}_dir")
        filename = self.send("#{name}_filename")
        File.join(dir, filename)
      end
      
      define_method("#{name}=") do |uploaded_file|
        if uploaded_file
          self.send("#{name}_filename=", uploaded_file.original_filename)
          FileUtils.mkdir_p(self.send("#{name}_dir"))
          FileUtils.mv(uploaded_file.path, self.send("#{name}_path"))
        else
          self.send("#{name}_filename=", nil)
        end
      end
      
      define_method("has_#{name}?") do
        self.send("#{name}_filename?") &&
        File.exist?(self.send("#{name}_path"))
      end
      
      define_method(name) do
        File.read(self.send("#{name}_path")) if self.send("has_#{name}?")
      end
    end
  end
end
