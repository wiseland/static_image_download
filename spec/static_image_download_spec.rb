#
#static_image_download_spec.rb
#extern libs
require './static_image_download/images.rb'
require './static_image_download/parser.rb'
require './static_image_download.rb'
require 'rspec'

include StaticImageDownloader

describe Downloader do
	before(:all) do
		@sid = Downloader.new("http://feed.informer.com")
	end
	
	it 'has a valid url' do
		@sid.url.should match /^(http|https|ftp)\:\/\//i
	end
	
	it 'has a string path' do
		@sid.path.should be_an_instance_of String
	end
	
	describe 'an arrray container for pictures (images)' do
		it 'has an arrray container' do
			@sid.images.should be_an_instance_of Array
		end
		
		it 'should has an empty arrray container' do
			@sid.images.should be_empty
		end
	end
end