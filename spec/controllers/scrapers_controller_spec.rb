require 'rails_helper'

RSpec.describe ScrapersController, type: :controller do 
	let(:special_param) { "ocean" }
	let(:css_class_to_count) { "row" }
	let(:resulting_hash) do
		{
			url: url,
			robots_txt_exists: true,
			robots_forbidden: false,
			bootstrap_user: true,
			string_to_search_for: special_param,
			string_in_dom: true,
			css_class_to_count: css_class_to_count,
			css_class_count: 3
		}
	end

	describe 'create' do
		
		before(:each) do
			post :create, url: url, string_to_search_for: special_param, css_class_to_count: css_class_to_count
		end

		context 'when valid params supplied' do
			context 'when string is in DOM, bootstrap user, robots.txt exists but does not forbid-' do
				let(:url) { "http://www.hydearchitects.com/" }
				it 'returns in JSON an HTML body, whether special param is in HTML body, whether robots.txt exists, whether bootstrap is used' do
					expect(response.status).to eq(200)
					expect(JSON.parse(response.body)).to eq(JSON.parse(resulting_hash.to_json))
				end
			end
			context 'when bootstrap is in HTML DOM, but site does not use bootstrap' do
				let(:url) { "http://www.agilestartup.com/making-money/go-bootstrap-yourself/" }
				it 'returns false for bootstrap user' do
					expect(JSON.parse(response.body)["bootstrap_user"]).to be false
				end
			end
			context 'when site forbids crawling' do
				let(:url) { "https://www.facebook.com/onthisday/?source=bookmark" }
				it 'returns true for robots forbidden' do
					expect(JSON.parse(response.body)["robots_forbidden"]).to be true
				end
			end
			context 'when robots.txt is empty/full only of comments' do
				let(:url) { "https://judge-my-routine.herokuapp.com" }
				it 'returns false for robots_txt_exists' do
					expect(JSON.parse(response.body)["robots_txt_exists"]).to be false
				end
			end
			context 'when robots.txt DNE' do
				let(:url) { "http://www.wordtwist.org/" }
				it 'returns false for robots_txt_exists, returns 200' do
					expect(response.status).to eq(200)
					expect(JSON.parse(response.body)["robots_txt_exists"]).to be false
				end
			end
		end
		context 'when invalid params are supplied - url is invalid and/or when cannot retrieve page' do
			let(:url) { "www.wiryhipposaretooskinny.com/"}
			it 'returns 400 with error message asking for formatted or proper url' do
				expect(response.status).to eq(400)
				expect(JSON.parse(response.body)["errors"]).to eq("URL is wrong or improperly formatted")
			end
		end
	end
end
