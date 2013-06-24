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
      before(:all) do
        20.times { FactoryGirl.create(:micropost, user: user, content: "Lorem blah blah ipsum") }
      end
      after(:all) {User.delete_all}
      before do
        FactoryGirl.create(:micropost, user: another, content: "Cant delete this")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end
      it { should have_selector('span', text: "#{user.microposts.count} microposts") }
      #describe "pagination" do
      #  it { should have_selector('pagination') }
      #  it "should list each micropost feed" do
      #    Micropost.paginate(page: 1).each do |m|
      #      page.should have_selector('content', text: m.content)
      #    end
      #  end
      #end
      it { should_not have_link('delete', href: "microposts/#{another.microposts.last}")}
      describe "following/followers stats" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(@user)
          visit root_path
        end
        it { should have_link("0 following", href: following_user_path) }
        it { should have_link("1 followers", href: followers_user_path) }
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
