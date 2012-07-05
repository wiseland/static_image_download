#
#Created by Alex Lapin

module StaticImageDownloader
	class Parser
		attr_accessor	:url, :content, :parse_option, :user_agent, :images, :extracted_links
		
		PARSER_OPTIONS = {
			'URI_EXTRACT'		=>	:img_parse_uri_extract,
			'NOKOGIRI'			=>	:img_parse_nokogiri,
			'HPRICOT'			=>	:img_parse_hpricot
		}
		PARSER_OPTIONS.default 	= 	:img_parse_uri_extract
		
		@@DEFAULTPARSEOPTION 	= 'URI_EXTRACT' #also you can use one 'NOKOGIRI' or 'HPRICOT'
		@@DEFAULTUSERAGENT 		= 'Mozilla/5.0'
		@@DEFAULTPATH 			= "./"
		@@DEFAULTSITE 			= 'http://feed.informer.com'
		@@DEFAULTTIMEOUT		= 15
		
		def initialize(url=@@DEFAULTSITE, path=@@DEFAULTPATH, parse_option=@@DEFAULTPARSEOPTION, timeout=@@DEFAULTTIMEOUT, user_agent=@@DEFAULTUSERAGENT, h={})
			@url 				= url.nil? ? @@DEFAULTSITE : url
			@user_agent 		= user_agent.nil? ? @@DEFAULTUSERAGENT : user_agent
			@path 				= path.nil? ? @@DEFAULTPATH : path
			@timeout 			= timeout.nil? ? @@DEFAULTTIMEOUT : timeout
			@parse_option 		= parse_option.nil? ? @@DEFAULTPARSEOPTION : parse_option
			@images 			= []
			@extracted_links 	= []
			@rgxp_img_uri 		= Regexp.new(/^(http|https|ftp)\:\/\/([a-zA-Z0-9\.\-]+(\:[a-zA-Z0-9\.&amp;%\$\-]+)*@)?((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.[a-zA-Z]{2,4})(\:[0-9]+)?(\/[^\/][a-zA-Z0-9\.\,\?\'\\\/\+&amp;%\$#\=~_\-@]*)\.(#{Images::IMAGE_EXT.join('|')})/i)
			#@rgxp_img_uri 		= Regexp.new(/^(((http|https|ftp)\:\/\/)|www|(\/\/))([a-zA-Z0-9\.\-]+(\:[a-zA-Z0-9\.&amp;%\$\-]+)*@)?((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.[a-zA-Z]{2,4})(\:[0-9]+)?(\/[^\/][a-zA-Z0-9\.\,\?\'\\\/\+&amp;%\$#\=~_\-@]*)\.(#{Images::IMAGE_EXT.join('|')})/i)
			@domain 			= URI.parse(url).host
			@content			= nil
		end
		
		class << self
			def default_parse_option
				@@DEFAULTPARSEOPTION
			end
			
			def default_user_agent
				@@DEFAULTUSERAGENT
			end
			
			def default_path
				@@DEFAULTPATH
			end
			
			def default_timeout
				@@DEFAULTTIMEOUT
			end
		end
		
		def option_to_method(option)
			opt = PARSER_OPTIONS[option]
		end
		
		def method_to_value(option, h={})
			method = option_to_method(option)
			p "method= #{method}" if $debug_option
			begin
				response = send(method, h) || ""
				return response
			rescue => error
				p "method_to_value.error = #{error}"
				nil
			end
		end
		
		def get_content_raw
			@content = self.get_url.read
			@content.gsub!(/[\n\r\t]+/,' ')
			#p @content if $debug_option
		end
		
		def get_url
			open(self.url, 'User-Agent' => self.user_agent)
		end
		
		def img_parse_nokogiri(h={})
			doc = Nokogiri::HTML(@content)
			get_extracted_links(doc.search("//img"))
		end
		
		def img_parse_hpricot(h={})
			doc = Hpricot(@content)
			get_extracted_links(doc.search("//img"))
		end
		
		def img_parse_uri_extract(h={})
			get_extracted_links(URI.extract(@content).select{ |l| l[/#{@rgxp_img_uri}/] })
		end
		
		def get_extracted_links(links)
			return false unless links 
			links.each do |link|
				p "link= #{link}" if $debug_option
				link = link[:src].to_s unless link.is_a?(String)
				@extracted_links << link.match(@rgxp_img_uri)[0] if link.match(@rgxp_img_uri) and !@extracted_links.include?(link.match(@rgxp_img_uri)[0])
			end
			#p "extracted_links= #{@extracted_links}" if $debug_option
		end
		
		def parse_images(h={})
			begin
				response = nil
				status = Timeout::timeout(@timeout) {
					response = method_to_value(self.parse_option, h)
					collect_images
				}
			rescue => error
				p "#{error}"
				nil
			end
		end
		
		def collect_images
			@extracted_links.each do |link|
				self.push_image(link)
			end
		end
		
		def push_image(src)
			self.images.push Images.new(src, @path, Images.default_download_option)
		end
	end
end
		