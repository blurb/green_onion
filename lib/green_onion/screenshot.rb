require 'capybara/dsl'
require "fileutils"

module GreenOnion
	class Screenshot
		include Capybara::DSL

		attr_accessor :dir 
		attr_reader :paths_hash

		def initialize(params = {})
			Capybara.default_driver = :selenium
			@dir = params[:dir]
			@paths_hash = {}
		end

		def snap_screenshot(url, path)
			visit url
			Capybara.page.driver.browser.save_screenshot(path)
		end

		def test_screenshot(url)
			url_to_path(url)
			snap_screenshot(url, @shot_path)
		end

		def url_to_path(url)
			get_path(url)
			if File.exist?(@paths_hash[:original])
				@paths_hash[:fresh] = @paths_hash[:original].dup.insert(-5, '_fresh')
				@shot_path = @paths_hash[:fresh]
			else
				@shot_path = @paths_hash[:original]
			end
			return @shot_path
		end	

		def get_path(url)
			@filename = url.match(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/)[5]
			if @filename.empty? || @filename == '/' 
				@paths_hash[:original] = "#{@dir}/root.png"
			else
				@filename = @filename.gsub(/[\/]/, '')
				@paths_hash[:original] = "#{@dir}/#{@filename}.png"
			end
		end

		def destroy(url)
			get_path(url)
			if File.exist?( @paths_hash[:original] )
				FileUtils.rm( @paths_hash[:original] )
				if File.exist?( @paths_hash[:fresh] )
					FileUtils.rm( @paths_hash[:fresh] ) 
				end
			end
		end

	end
end