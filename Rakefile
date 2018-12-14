require "#{Dir.pwd}/helpers/rake_helpers"
include RakeHelpers

desc 'Launch a server daemon with live reloading'
task :preview do
  system('bundle exec middleman')
end

desc 'Deploy the build folder to Github pages'
task :deploy do
  puts 'Removing existing build folder'
  `rm -rf build`
  puts 'Building and deploying site to master'
  `bundle exec mgd --branch master`
  `git checkout source`
end

desc 'Create a post file and folder'
task :post, :title do |_, args|
  title = args[:title]
  slug = slugify(title)

  post_dir      = File.join('source', 'articles')
  post_filename = [Time.now.strftime("%F"), slug].join('-')
  post_path     = File.join(post_dir, "#{post_filename}.html.md")
  post_folder   = File.join(post_dir, post_filename)
  post = <<-POST
---
title: #{title}
date: #{Time.now.strftime("%F")}
tags:
layout: post
---
  POST

  File.write(post_path, post)
  Dir.mkdir(post_folder)
end
