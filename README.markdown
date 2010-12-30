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

## Usage:

Using the above example, your model should look like this:

    require 'big_secret_files'

    class Microprocessor < ActiveRecord::Base
      extend BigSecretFiles::Attachable # Yep, no monkey-patching here
      
      has_big_secret :code
      has_big_secret :checksum
    end

In your view, just use normal file upload fields:

    Code file: <%= file_field(:microprocessor, :code) %><br>
    Checksum file: <%= file_field(:microprocessor, :checksum) %>
    
And in your controller you can handle the uploads with normal assignment:

    @microprocessor.code = params[:microprocessor][:code]
    @microprocessor.checksum = params[:microprocessor][:checksum]

**NOTE:** The record you're adding files to must already exist (i.e. it must
have an `id`). This won't affect your `update` action, but if you want to
upload files on `create`, you'll need to jump through the appropriate hoops.

The files will be uploaded to a directory scoped to the rails env and record id. For example:

    [rails_root]/data/[rails_env]/codes/[record_id]/[original filename] and
    [rails_root]/data/[rails_env]/checksums/[record_id]/[original filename]

You can do what you want with this. Be sure to make sure the data dir is
shared between releases if you use something like capistrano. The plugin won't
do that for you.

To interact with uploaded files in your app code, the plugin adds the
some handy methods to your model:

     # To get the base directory where the files are saved:
     microprocessor.code_dir
     microprocessor.checksum_dir.

     # To get the full filesystem path to the files:
     microprocessor.code_path
     microprocessor.checksum_path

     # To check if a file exists:
     microprocessor.has_code?
     microprocessor.has_checksum?

     # To get the contents of the files:
     microprocessor.code
     microprocessor.checksum

## TODO:

* Handle uploads to new records.
