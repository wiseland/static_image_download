#
#parser_spec.rb
#extern libs
require './static_image_download/images.rb'
require './static_image_download/parser.rb'
require './static_image_download.rb'
require 'rspec'

include StaticImageDownloader

describe Parser do
	before(:all) do
		@parser = Parser.new("http://feed.informer.com", "download_images")
	end
	
	it 'has a valid url' do
		@parser.url.should match /^(http|https|ftp)\:\/\//i
	end
	
	it 'has default init parse option' do
		described_class.default_parse_option.should eq 'URI_EXTRACT'
	end

	it 'has default init user agent' do
		described_class.default_user_agent.should eq 'Mozilla/5.0'
	end
	
	it 'has default init path' do
		described_class.default_path.should eq './'
	end
	
	it 'has default init timeout' do
		described_class.default_timeout.should eq 15
	end
		
	it 'has default parse option' do
		described_class::PARSER_OPTIONS['bad_key'].should eq :img_parse_uri_extract
	end
	
	it 'should has an empty arrray container' do
		@parser.images.should be_empty
	end
	
	it 'should has an empty extracted_links' do
		@parser.images.should be_empty
	end
	
	describe 'parse content' do
		it 'should get raw content' do
			@parser.get_content_raw.should_not be_nil
		end
		
		it 'should parse raw content within URI_EXTRACT' do
			@parser.extracted_links.clear
			@parser.img_parse_uri_extract
			@parser.extracted_links.should_not be_empty
		end
		
		it 'should parse raw content within NOKOGIRI' do
			@parser.extracted_links.clear
			@parser.img_parse_nokogiri
			@parser.extracted_links.should_not be_empty
		end
		
		it 'should parse raw content within HPRICOT' do
			@parser.extracted_links.clear
			@parser.img_parse_hpricot
			@parser.extracted_links.should_not be_empty
		end
	end
	
	describe 'parse images' do
		it 'should parse images and push their sources into image array' do
			@parser.images.clear
			@parser.parse_images
			@parser.images.should_not be_empty
		end
	end
end