#
#Created by Alex Lapin

module StaticImageDownloader
	class Images
		attr_accessor :src, :file_base_name, :file_path_name, :full_path_name, :page_host, :absolute_src 

		MAX_FILE_NAME_LENGTH = 100
		IMAGE_EXT = ["jpg", "jpeg", "png", "gif", "ico", "svg", "bmp"]
		EMPTY_FILE_NAME 		= 'EMPTY_'
		
		DOWNLOAD_OPTIONS = {
			'CURB_EASY'			=> :curb_simple,
			'HTTP_GET'			=> :http_get
		}
		DOWNLOAD_OPTIONS.default = :curb_simple

		@@DEFAULTDONWLOADOPTION = 'CURB_EASY'
		@@HTTPONSUCCESS			= Regexp.new(/^20\d$/)
		@@DEFAULTPATH			= "./"
		@@DEFAULTTIMEOUT		= 120
		@@SUCCESSFULLPICTURES	= 0
		
		def initialize(src, file_path_name=@@DEFAULTPATH, download_option=@@DEFAULTDONWLOADOPTION, page_host="")
			@src 				= src
			@page_host 			= page_host	# Reserved for future
			@download_option	= download_option.nil? ? @@DEFAULTDONWLOADOPTION : download_option
			@file_path_name 	= file_path_name.nil? ? @@DEFAULTPATH : file_path_name.gsub(/\/+$/,'')
			
			file_base_name 		= @src.sub(/.*\//,'')
			file_base_name 		= EMPTY_FILE_NAME + rand(1000).to_s if !file_base_name || file_base_name.empty?
			if file_base_name.size > MAX_FILE_NAME_LENGTH
				file_base_name = file_base_name[-MAX_FILE_NAME_LENGTH..file_base_name.size]
			end
			
			@file_base_name = file_base_name
			@file_full_name = File.expand_path(File.join(@file_path_name, @file_base_name))
			
			@full_path_name = File.expand_path(File.join(@file_path_name)) 
			Dir::mkdir(@full_path_name) unless FileTest.directory?(@full_path_name)
		end
		
		class << self
			def default_download_option
				@@DEFAULTDONWLOADOPTION
			end
			
			def default_path
				@@DEFAULTPATH
			end
			
			def default_timeout
				@@DEFAULTTIMEOUT
			end
			
			def get_successfull_pictures_number
				@@SUCCESSFULLPICTURES.to_s
			end
			
			private
			def inc_successfull_pictures_number
				@@SUCCESSFULLPICTURES += 1
			end
		end
		
		def download(download_option=@@DEFAULTDONWLOADOPTION, timeout=@@DEFAULTTIMEOUT, h={:dup_file_names => true})
			#p "download_option=#{download_option}"
			begin
				response = nil
				status = Timeout::timeout(timeout) {
					h[:start_time] = Time.now
					response = method_to_value(download_option, h)
				}
			rescue => error
				p "#{error}"
				nil
			end
		end
		
		def option_to_method(option)
			opt = DOWNLOAD_OPTIONS[option]
		end
		
		def method_to_value(option, h={})
			#p "option= #{option}"
			method = option_to_method(option)
			p "method= #{method}" if $debug_option
			begin
				response = send(method, h) || ""
				@@SUCCESSFULLPICTURES += 1 if response[:path]
				return response
			rescue => error
				p "method_to_value.error = #{error}"
				nil
			end
		end
		
		private
		
		def print_download_log(rcode, file_full_name, h={})
			if @@HTTPONSUCCESS !~ rcode
				p "Error: html_res_code=" + rcode + " " + (Time.now - h[:start_time]).to_s + " sec. for #{File.basename(file_full_name)} File could not be saved!"
			else
				p "html_res_code=" + rcode + " " + (Time.now - h[:start_time]).to_s + " sec. for #{File.basename(file_full_name)}" if $debug_option 
			end
		end
		
		def check_file_name(src, h={})
			result = {}
			response = {}
			file_full_name = @file_full_name
			fname_counter = 1
			if File.exist?(file_full_name) and !h[:dup_file_names]
				response[:error] = "Error downloading. File #{file_full_name} already exists"
				p response[:error]
				p " src= #{src}" if $debug_option
				result[:response] = response
				#return result
			else
				while File.exist?(file_full_name)
					fname_counter += 1;
					file_full_name = File.dirname(@file_full_name) + '/' + File.basename(@file_full_name, '.*') + '_' + fname_counter.to_s + File.extname(@file_full_name)
				end
				result[:file_full_name] = file_full_name
				#File.new(file_full_name, "wb").close
			end
			return result
		end
		
		def curb_simple(h={})
			response = {}
			src = @src
			result = check_file_name(src, h)
			response = result[:response] if result[:response]
			return response if response[:error]
			
			file_full_name = result[:file_full_name]
			begin
				curl = Curl::Easy.download(src, file_full_name)
				rcode = curl.response_code.to_s
				#p "response_code=" + rcode if $debug_option
				unless @@HTTPONSUCCESS =~ rcode
					File.delete(file_full_name) if File.exist?(file_full_name)
				end
				print_download_log(rcode, file_full_name, h)
				rpath = file_full_name if File.exist?(file_full_name)
			rescue => error
				response[:error] = error.message
				File.delete(file_full_name) if File.exist?(file_full_name)
			end
			
			response[:response_code] = rcode
			response[:path]          = rpath
			return response
		end
		
		def http_get(h={})
			response = {}
			src = @src
			result = check_file_name(src, h)
			response = result[:response] if result[:response]
			return response if response[:error]
			
			file_full_name = result[:file_full_name]
			begin
				answer = Net::HTTP.get_response(URI.parse(src))
				rcode = answer.code
				if @@HTTPONSUCCESS =~ rcode
					open(file_full_name, "wb") { |file|	file.write(answer.body) }
				end
				#p "response_code=" + answer.code if $debug_option
				print_download_log(rcode, file_full_name, h)
				rpath = file_full_name if File.exist?(file_full_name)
			rescue => error
				response[:error] = error.message
				File.delete(file_full_name) if File.exist?(file_full_name)
			end
			
			response[:response_code] = rcode
			response[:path]          = rpath
			return response
		end
	end
end
