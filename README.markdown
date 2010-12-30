# Big Secret Files

A Rails 2 plugin for uploading files to the filesystem as simply as possible.

Uploaded files are kept on the filesystem, not read into memory when uploaded
(you can read them later if you want), and they aren't stored in a
web-accessible directory. Because of this, large files are handled with ease,
and the code is super simple.

This was originally written for a legacy project. I have paid zero attention
to making sure it is compatible with Rails 3. Sorry.

If you're on Rails 3 or you want publicly-accessible file attachments, image
resizing, S3 storage, etc. then this is [not *for* you](http://www.penny-arcade.com/comic/2004/3/24/).
You should be using [Paperclip](https://github.com/thoughtbot/paperclip).

## Installation

Don't install it. Nothing works yet.
