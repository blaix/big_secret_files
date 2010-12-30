require 'fileutils'

module BigSecretFiles
  module Attachable
    # Usage:
    #
    #     require 'big_secret_files'
    #     class MyModel < ActiveRecord::Base
    #       extend BigSecretFiles::Attachable
    #       has_big_secret :document
    #     end
    # 
    # Where :document is the name you want to give to the attribute. You can
    # define as multiple by calling the method multiple times. The following
    # methods will be added to your model (method names, paths, etc. will
    # match the name you pass to has_big_secret):
    #
    #     my_model.document_dir
    #     # The base directory where the file will be saved. Defaults to:
    #     # RAILS_ROOT/data/[RAILS_ENV]/documents/[my_model.id]
    #     # Redefine this method in your model if you want to change this.
    #     # NOTE: you'll want to make sure the `data` dir is shared between
    #     # releases if you're using capistrano. This plugin won't do that for
    #     # you.
    #
    #     my_model.document_path
    #     # The full path to the file.
    #
    #     my_model.document=(uploaded_file)
    #     # The method that actually saves the file.
    #     # Use it in your controllers like: my_model.document = params[:file]
    #     # NOTE: You can't use this on new records (it has to have an id).
    #
    #     my_model.has_document?
    #     # boolean method to determine if a document exists.
    #
    #     my_model.document
    #     # Returns the contents of the file. Your file will never be read
    #     # into memory until this method is called by you (it's never called
    #     # internally).
    def has_big_secret(name)
      define_method("#{name}_dir".to_sym) do
        return nil if new_record?
        File.expand_path(RAILS_ROOT + "/data/#{ENV['RAILS_ENV']}/#{name.to_s.pluralize}/#{id}")
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
