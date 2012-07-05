#!/usr/local/bin/ruby

# Created by Alex Lapin

require 'rubygems'
require 'open-uri'
require 'benchmark'
#require 'ruby-debug'

d_url = ARGV[0].nil? ? "http://edition.cnn.com/" : ARGV[0].to_s
p "download url= #{d_url}"
unless d_url.match(/^(http|https|ftp)\:\/\//i)
	p "URL is invalid. It must start with 'http://'"
	exit
end
d_dir = ARGV[1].nil? ? Dir::pwd + "/" + "#{URI.parse(d_url).host}_img" : Dir::pwd + "/" + ARGV[1].to_s
p "download dir= #{d_dir}"


# To see more information set $debug_option to true
$debug_option = false

	image_downloader = ""
	Benchmark.bm do |x|
		begin
			# If you don't have curb, nokogiri, hpricot gems installed in the system, they will be loading automatically from dir './libs'
			# But it'll take some time to load libraries/ Please wait...
			x.report("Loading libraries:") do
				#require File.dirname(__FILE__) + '/static_image_download.rb'
				require 'static_image_download'
				include StaticImageDownloader
			end
			
			x.report("Initialize:") { image_downloader = Downloader.new(d_url, d_dir) }
			
			# You can use 'URI_EXTRACT' (default) or 'NOKOGIRI' or 'HPRICOT' options to parse the picture links
			# An exapmle: image_downloader.parse_images(parse_option='URI_EXTRACT', parse_timeout=10, user_agent='Mozilla/5.0')
			# These params are used by default. So you can call image_downloader.parse_images without params 
			x.report("Pasre links:") { image_downloader.parse_images('URI_EXTRACT', 10, 'Mozilla/5.0') }
			
			# You can use 'CURB_EASY' (default - fastest) or 'HTTP_GET' options to get the pictures
			# An example: image_downloader.parallel_download(download_option='CURB_EASY', download_timeout=120, allow_dup_files=true)
			# Set allow_dup_files=true if you want file duplicates: file1, file2, ... etc, otherwise set allow_dup_files=false
			# These params are used by default. So you can call image_downloader.parallel_download without params 
			x.report("Parallel download pictures:") { image_downloader.parallel_download('CURB_EASY', 120, true) }
			
			# Consequential download is slower than Parallel download
			# Uncomment code below if you want to use consequential download pictures
			#x.report("Consequential download pictures:") { image_downloader.consequential_download }
		rescue
			p "Error downloading images!"
		end
	end