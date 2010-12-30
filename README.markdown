# Big Secret Files

A Rails 2-style plugin for uploading files to the filesystem as simply as
possible.

Uploaded files are kept on the filesystem, not read into memory when uploaded
(you can read them later if you want), and they aren't stored in a
web-accessible directory. Because of this, large files are handled with ease,
and the code is super simple. Original file names are preserved.

This was originally written for a legacy project. I have paid zero attention
to making sure it is compatible with Rails 3, but it might be.

If you want publicly-accessible file attachments, image resizing, S3 storage,
etc. then this is [not *for* you](http://www.penny-arcade.com/comic/2004/3/24/).
You should be using [Paperclip](https://github.com/thoughtbot/paperclip).

## Installation

    ./script/plugin install git://github.com/blaix/big_secret_files.git
    
For each file attribute you want to add to your model, you'll have to add
a `[name]_filename` field to the db table. For example, if you want to add
`code` and `checksum` files to your `Microprocessor` model, you want a
migration that looks like this:

    def self.up
      add_column :microprocessors, :code_filename, :string
      add_column :microprocessors, :checksum_filename, :string
    end

    def self.down
      remove_column :microprocessors, :code_filename
      remove_column :microprocessors, :checksum_filename
    end

## Usage

Using the above example, your model should look like this:

    require 'big_secret_files'
    
    class Microprocessor < ActiveRecord::Base
      extend BigSecretFiles::Attachable # Yep, no monkey-patching here
      
      has_big_secret :code
      has_big_secret :checksum
    end

In your view:

    TODO: view example
    
In your controller:

    TODO: controller example
