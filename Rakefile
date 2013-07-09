require "rubygems"
require "bundler/setup"
require "stringex"

source_dir      = "."    # source file directory
posts_dir       = "_posts"    # directory for blog files

# usage rake new_post[my-new-post] or rake new_post['my new post'] or rake new_post (defaults to "new-post")
desc "Begin a new post in #{source_dir}/#{posts_dir}"
task :new_post, :title do |t, args|
	raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
	mkdir_p "#{source_dir}/#{posts_dir}"
	args.with_defaults(:title => 'new-post')
	title = args.title
	filename = "#{source_dir}/#{posts_dir}/#{Time.now.localtime.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
	if File.exist?(filename)
		abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
	end
	puts "Creating new post: #{filename}"
	open(filename, 'w') do |post|
	post.puts "---"
	post.puts "layout: post"
	post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
	post.puts "date: #{Time.now.localtime.strftime('%Y-%m-%d %H:%M')}"
	post.puts "meta: true"
	post.puts "---"
	end
end

