---
title: Starting afresh with Middleman
date: 2016-02-01
tags: Blog
layout: post
---

For the (3rd, 4th?) time I've decided to re-launch my blog. I thought I'd start with a brief post on some of the minor technical details of my experience in switching to use [Middleman](https://middlemanapp.com/) and [Middleman-Blog](https://middlemanapp.com/basics/blogging/). I've used both Jekyll and Octopress in the past for my blog, but life is for learning - right?

Rather than start from scratch, I decided to find an existing template to get me started as quickly as possible. I settled on [Middleman-Casper](https://github.com/danielbayerlein/middleman-casper), a theme based on [Casper](https://github.com/TryGhost/Casper) (the default theme for [Ghost](https://ghost.org/), and Middleman 4.

I've used Middleman in the past (we use it to power the [Terracoding](http://www.terracoding.com) website too), and can really get behind the idea (and advantages) of a static site. Unfortunately the Terracoding site uses an older version of Middleman, so there were a few quirks and differences when it came to using version 4.0.

There seems to be a few issues with [middleman-deploy](https://github.com/middleman-contrib/middleman-deploy), where deploying would push the root folder instead of the intended build folder ([#114](https://github.com/middleman-contrib/middleman-deploy/issues/114)). Instead I used [mgd](https://github.com/hovancik/middleman-github-deploy), a fork of the build script to deploy Jekyll to Github Pages.

Version 4 of Middleman also [removes the article command](https://github.com/middleman/middleman-blog/issues/268), as a result I wrapped this and the other mish-mash of functionality in a single Rakefile, standardising the commands/interactions.

``` ruby
require "#{Dir.pwd}/helpers/rake_helpers"
include RakeHelpers

desc 'Launch a server daemon with live reloading'
task :preview do
  # use system to pass the CTRL-D to the child process
  system('middleman')
end

desc 'Deploy the build folder to Github pages'
task :deploy do
  puts 'Removing existing build folder'
  `rm -rf build`
  puts 'Building and deploying site to master'
  `mgd --branch master`
  `git checkout source`
end

desc 'Create a post file and folder'
task :post, :title do |t, args|
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
```

