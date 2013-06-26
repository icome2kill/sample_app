require 'spec_helper'

describe "Static pages" do
  subject {page}
  shared_examples_for "All static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before {visit root_path}
    let(:heading) {'Sample App'}
    let(:page_title) { '' }
    it_should_behave_like "All static pages"
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:another) { FactoryGirl.create(:user) }
      before do
        35.times { user.microposts.create!(content: "Blah Blah BLah blah") }
        FactoryGirl.create(:micropost, user: another, content: "Can't see this")
        sign_in user
        visit root_path
      end
      after(:all) { Micropost.delete_all }
      describe "paginate" do
        it { should have_selector('div.pagination') }
      end
      it "should render the user's feed" do
        user.feed.paginate(page: 1).each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end
      it { should have_selector('span', text: "#{user.microposts.count} microposts") }
      it { should_not have_link('delete', href: "microposts/#{another.microposts.last}")}
      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end
    end
  end
  describe "Help page" do
    before { visit help_path}
  	let(:heading) { 'Help' }
    let(:page_title) { 'Help' }
    it_should_behave_like "All static pages"
  end
  describe "About page" do
    before { visit about_path }
  	let(:heading) { 'About Us' }
    let(:page_title) { 'About' }
    it_should_behave_like "All static pages"
  end
  describe "Contact page" do
    before { visit contact_path }
    let(:heading) {'Contact'}
    let(:page_title) {'Contact'}
    it_should_behave_like "All static pages"
  end
  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us') 
    click_link "Help"
    page.should have_selector('title', text: full_title('Help'))
    click_link "Contact"
    page.should have_selector('title', text: full_title('Contact'))
    click_link "Home"
    click_link "Sign up now!"
    page.should have_selector('title', text: full_title('Sign up'))
    click_link "sample app"
    page.should have_selector('title', text: full_title(''))
  end
end
