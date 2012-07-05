#
#images_spec.rb
#extern libs
require 'static_image_download.rb'
require 'rspec'

include StaticImageDownloader

describe Images do
	before(:all) do
		@image = Images.new("http://feed.informer.com")
	end

	it 'has default init donwload option' do
		described_class.default_download_option.should eq 'CURB_EASY'
	end
	
	it 'has default init download path' do
		described_class.default_path.should eq './'
	end
	
	it 'has default init timeout' do
		described_class.default_timeout.should eq 120
	end
		
	it 'has default download option' do
		described_class::DOWNLOAD_OPTIONS['bad_key'].should eq :curb_simple
	end
	
	it 'should has an empty pictures downloaded' do
		described_class.get_successfull_pictures_number.to_i.should be_zero
	end
	
	it 'should has an exist download directory' do
		FileTest.directory?(@image.full_path_name).should be_true
	end
	
	it 'should has a valid abs src' do
		uri = URI.parse(@image.src)
		%w( http https ).include?(uri.scheme).should be_true
	end
	
	describe 'image downloader' do
		it 'should get a valid response' do
			@image.src = "http://www.walls-world.ru/wallpapers/nature/wallpapers_8120_1280x960.jpg"
			@image.download[:path].should_not be_nil
		end
		
		it 'should get a picture within curb' do
			@image.src = "http://www.walls-world.ru/wallpapers/nature/wallpapers_8120_1280x960.jpg"
			@image.download('CURB_EASY')[:path].should_not be_nil
		end
		
		it 'should get a picture within http::get' do
			@image.src = "http://www.walls-world.ru/wallpapers/nature/wallpapers_8120_1280x960.jpg"
			@image.download('HTTP_GET')[:path].should_not be_nil
		end
		
		it 'should get an error' do
			@image.src = "http://picture/1280x960.jpg"
			@image.download[:path].should be_nil
		end
	end
end