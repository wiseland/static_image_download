#
#Created by Alex Lapin
# core libs
require 'timeout'
require 'open-uri'
require 'net/http'

# extern libs
require File.dirname(__FILE__) + '/static_image_download/images.rb'
require File.dirname(__FILE__) + '/static_image_download/parser.rb'
begin 
	require 'curb'
rescue LoadError => e
	p "No curb installed"
end

begin 
	require 'hpricot'
rescue LoadError => e
	p "No hpricot installed"
end

begin 
	require 'nokogiri'
rescue LoadError => e
	p "No nokogiri installed"
end

#require 'hpricot'
#require 'nokogiri'
# Comment below 2 libraries to reduce total library loading time if you dont need them
# If you have them installed in your system just uncomment above 2 libraries
#require File.dirname(__FILE__) + '/libs/hpricot-0.8.6/lib/hpricot'
#require File.dirname(__FILE__) + '/libs/nokogiri-1.5.3/lib/nokogiri'



module StaticImageDownloader
	
	class Downloader
	
		attr_accessor :url, :path, :images

		@@DEFAULTPATH = 'images'	# Default path for images
		
		# This is just for info:
		# user_agent 	   - Parse::DEFAULTUSERAGENT 		= 'Mozilla/5.0'
		# parse_timeout    - Parse::DEFAULTTIMEOUT			= 10
		# parse_option 	   - Parse::DEFAULTPARSEOPTION 		= 'URI_EXTRACT' # also you can use one 'NOKOGIRI' or 'HPRICOT'
		# download_timeout - Image::DEFAULTTIMEOUT			= 120
		# Image::DEFAULTDONWLOADOPTION						= 'CURB_EASY'	# also you can use 'HTTP_GET'
		# allow_dup_files  - dup_file_names					= false 		# don't get file if exists one
		# allow_dup_files  - dup_file_names [DEFAULT option]= true 			# get file if it exists as new one and add numerical prefix (1,2,3, etc.) to it's name
	
		def initialize(url, path=@@DEFAULTPATH)
			@url = url
			@path = path.nil? ? @@DEFAULTPATH : path
			@images = []
		end
		
		def self.default_path
			@@DEFAULTPATH
		end
		
		def parse_images(parse_option='URI_EXTRACT', parse_timeout=10, user_agent='Mozilla/5.0')
			parser = Parser.new(self.url, self.path, parse_option, parse_timeout, user_agent)
			parser.get_content_raw
			parser.parse_images
			self.images = parser.images
		end
		
		def parallel_download(download_option='CURB_EASY', download_timeout=120, allow_dup_files=true)
			threads = []
			self.images.each do |img|
				threads << Thread.new(img) { |image| image.download(download_option, download_timeout, :dup_file_names => allow_dup_files) }
			end
			threads.each { |aThread|  aThread.join }
			p "Total " + Images::get_successfull_pictures_number + " pictures were got"
		end
		
		def consequential_download(download_option='CURB_EASY', download_timeout=120, allow_dup_files=true)
			self.images.each { |img| img.download(download_option, download_timeout, :dup_file_names => allow_dup_files) }
			p "Total " + Images::get_successfull_pictures_number + " pictures were got"
		end
	end
end
