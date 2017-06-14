class ScrapersController < ApplicationController
	respond_to :json

	def create
	# def simple_info
		begin
			page = HTTParty.get(set_params[:url])

			robots_url = set_params[:url].split("//").first + "//" + set_params[:url].split("//").last.split("/").first + "/robots.txt"
			# classify robots_txt as 'nonexistent' even if loaded on page if there are no lines that are not comments
			robots_txt = HTTParty.get(robots_url).parsed_response
			robots_uncommented_txt = robots_txt.split("\n").delete_if{|l| l.start_with?("#")}.join("\n") unless robots_txt.nil?
			robots_forbidden = if !robots_uncommented_txt.present? then false else robots_uncommented_txt.end_with?("User-agent: *\nDisallow: /") end

			response = {
				url: set_params[:url],
				robots_txt_exists: robots_uncommented_txt.present?,
				robots_forbidden: robots_forbidden,
				bootstrap_user: page.partition("<head>").last.partition("</head>").first.include?("bootstrap.css"),
				string_to_search_for: set_params[:string_to_search_for],
				string_in_dom: page.include?(set_params[:string_to_search_for]),
				css_class_to_count: set_params[:css_class_to_count],
				css_class_count: page.scan("class=\""+set_params[:css_class_to_count]+"\"").count
			}

			render json: response.to_json, status: :ok
		rescue
			render json: { errors: "URL is wrong or improperly formatted" }, status: :bad_request
		end
	end

	private
	
	def set_params
		params.permit(:url, :string_to_search_for, :css_class_to_count)
	end
end
