require 'spec_helper' 

describe ApplicationHelper do
	describe "full_title" do
		it "should include the page title" do
			full_title(:arg).should have_content(:arg) 
		end
		it "should include the base title" do
			full_title('').should have_content('Ruby on Rails Tutorial Sample App')
		end
	end
end