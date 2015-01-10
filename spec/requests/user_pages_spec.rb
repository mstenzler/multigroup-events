require 'spec_helper'

NAME_LABEL = "Name"
USERNAME_LABEL = "Username"
EMAIL_LABEL = "Email"
PASSWORD_LABEL = "Password"
CONFIRM_PASSWORD_LABEL = "Password confirmation"
GENDER_LABEL = "Gender"
BIRTHDATE_LABEL = "Birthdate"
TIME_ZONE_LABEL = "time-zone-select"
AGE_DISPLAY_TYPE_LABEL = "Age display type"
COUNTRY_LABEL = "Country"
ZIP_CODE_LABEL = "Zip code"
CHANGE_USERNAME_BUTTON = "Change Username"
CHANGE_EMAIL_BUTTON = "Change Email"
BIRTHDATE = Time.now - 25.years
USA_COUNTRY = "United States"
EXAMPLE_ZIP_CODE = "07030"

describe "User pages" do

  subject { page }

  #Creates the country so it will be in the form
  before(:all) do
    @us_country = FactoryGirl.create(:geo_country)
  end

  after(:all) do
    @us_country.destroy
  end

  describe "index" do
  	let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "signup" do
 
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submition" do
      	before { click_button submit }

      	it { should have_title('Sign up') }
      	it { should have_content('error') }
      end

      describe "after submit with bad email" do
      	before do
          fill_in NAME_LABEL,         with: "Example User"
          fill_in EMAIL_LABEL,        with: "user@example"
          fill_in PASSWORD_LABEL,     with: "foobar"
          fill_in CONFIRM_PASSWORD_LABEL, with: "foobar"
          click_button submit
        end

        it { should have_content('error') }
        it { should have_content('Email is invalid') }
      end

      describe "after submit with blank password" do
      	before do
          fill_in NAME_LABEL,         with: "Example User"
          fill_in EMAIL_LABEL,        with: "user@example.com"
          fill_in PASSWORD_LABEL,     with: ""
          fill_in CONFIRM_PASSWORD_LABEL, with: ""
          click_button submit
        end

        it { should have_content('error') }
        it { should have_content('Password can\'t be blank') }
      end

      describe "after submit with blank name" do
      	before do
          fill_in NAME_LABEL,         with: ""
          fill_in EMAIL_LABEL,        with: "user@example.com"
          fill_in PASSWORD_LABEL,     with: "foobar"
          fill_in CONFIRM_PASSWORD_LABEL, with: "foobar"
          click_button submit
        end

        it { should have_content('error') }
        it { should have_content('Name can\'t be blank') }
      end

      describe "after submit with blank email" do
      	before do
          fill_in NAME_LABEL,         with: "Example User"
          fill_in EMAIL_LABEL,        with: ""
          fill_in PASSWORD_LABEL,     with: "foobar"
          fill_in CONFIRM_PASSWORD_LABEL, with: "foobar"
          click_button submit
        end

        it { should have_content('error') }
        it { should have_content('Email can\'t be blank') }
      end

    	describe "after submit with mismatched password confirmation" do
      	before do
          fill_in NAME_LABEL,         with: "Example User"
          fill_in EMAIL_LABEL,        with: "user@example.com"
          fill_in PASSWORD_LABEL,     with: "foo"
          fill_in CONFIRM_PASSWORD_LABEL, with: "foobar"
          click_button submit
        end

        it { should have_content('error') }
        it { should have_content('Password confirmation doesn\'t match Password') }
      end

     	describe "after submit with password too short" do
      	before do
          fill_in NAME_LABEL,         with: "Example User"
          fill_in EMAIL_LABEL,        with: "user@example.com"
          fill_in PASSWORD_LABEL,     with: "foo"
          fill_in CONFIRM_PASSWORD_LABEL, with: "foo"
          click_button submit
        end

        it { should have_content('error') }
        it { should have_content('Password is too short ') }
      end
     
    end

    describe "with valid information" do
      before do
#        save_and_open_page
        fill_in NAME_LABEL,             with: "Example User"
        fill_in USERNAME_LABEL,          with: "example_user"
        fill_in EMAIL_LABEL,            with: "user@example.com"
        fill_in PASSWORD_LABEL,         with: "foobar"
        fill_in CONFIRM_PASSWORD_LABEL, with: "foobar"
        select 'Male',           from: "Gender" if CONFIG[:require_gender?] 
        if CONFIG[:require_birthdate?] 
          select BIRTHDATE.year, from: 'user_birthdate_1i'
          select 'January', from: 'user_birthdate_2i'
          select BIRTHDATE.day, from: 'user_birthdate_3i'
          select "Number", from: AGE_DISPLAY_TYPE_LABEL
        end
        select USA_COUNTRY, from: COUNTRY_LABEL if CONFIG[:require_country?]
        fill_in ZIP_CODE_LABEL, with: EXAMPLE_ZIP_CODE if CONFIG[:require_zip_code?]
        select "Eastern Time (US & Canada)", from: 'time-zone-select' if CONFIG[:require_time_zone?]
#        save_and_open_page
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        if CONFIG[:verify_email?]
          it { should have_title('Verify Email Address') }
        else
          it { should have_link('Sign out') }
          it { should have_title(user.name) }
          it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        end
      end

    end
  end

  if CONFIG[:verify_email?]
    describe "verify email" do

      let(:submit) { "Verify" }
      let(:user) { FactoryGirl.create(:user) }
      let(:verify_email_label) { 'Verify token' }

      before do
        user.save!
        visit new_user_verify_email_path(user) 
      end

      describe "page" do
        it { should have_title('Verify Email Address') }
      end

      describe "with blank token" do
        before { click_button submit }

        it { should have_content('error') }
      end

      describe "with invalid token" do 
        before do
          fill_in verify_email_label,  with: 'foobar'
          click_button submit
        end

        it { should have_content('error') }
        it { should have_title('Verify Email Address') }
      end

      describe "with valid token" do 
        before do
          opts = user.reset_email_validation_token
          user.save!
          fill_in verify_email_label,  with: opts[:token]
          click_button submit
        end

        it { should_not have_content('error') }
        it { should have_title('Email Validation Success') }
        specify do
          user_n = User.find_by_id(user) 
          expect(user_n.email_validated).to eq true 
        end
      end
    end
  end #if CONFIG[:verify_email?]

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
    	sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('Change Username', edit_username_path) }
      it { should have_link('Change Email', edit_user_email_path) }
      it { should have_link('Reset Password', new_password_reset_path()) }
    end

    describe "with invalid information" do
      before do 
        fill_in NAME_LABEL, with: " "
        click_button "Save changes" 
      end

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }

      before do
#        save_and_open_page
        fill_in NAME_LABEL,             with: new_name
        select_date(Date.new(1990,1,1), { from: 'user_birthdate'} ) if CONFIG[:require_birthdate?] 
        select 'Female',                 from: GENDER_LABEL if CONFIG[:require_gender?] 
        select UTC_TIME_ZONE_VALUE,      from: TIME_ZONE_LABEL if CONFIG[:require_time_zone?]
        click_button "Save changes"
        user
        @updated_user = reload_obj(user)
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(@updated_user.name).to  eq new_name }
      if CONFIG[:require_birthdate?] 
        specify { expect(@updated_user.birthdate).to eq Date.new(1990,1,1) }
      end
      if CONFIG[:require_gender?] 
        specify { expect(@updated_user.gender).to eq 'Female' }
      end
      if CONFIG[:require_time_zone?]
        specify { expect(@updated_user.time_zone).to eq UTC_TIME_ZONE_VALUE }
      end
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end
      specify { expect(reload_obj(user)).not_to be_admin }
    end

  end  

  describe "change email" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_email_path(user)
    end

    describe "page" do
      it { should have_content("Change Email") }
      it { should have_title("Change Email") }
    end

    describe "with invalid information" do

      describe "email blank" do
        before do 
          fill_in EMAIL_LABEL, with: " "
          click_button CHANGE_EMAIL_BUTTON 
        end

        it { should have_content('error') }
      end

      describe "invalid email format missing .com" do
        before do 
          fill_in EMAIL_LABEL, with: "foo@bar"
          click_button CHANGE_EMAIL_BUTTON 
        end

        it { should have_content('error') }
        it { should have_content('Email is invalid') }
      end

      describe "invalid email format missing @" do
        before do 
          fill_in EMAIL_LABEL, with: "foobar.com"
          click_button CHANGE_EMAIL_BUTTON 
        end

        it { should have_content('error') }
        it { should have_content('Email is invalid') }
      end
     
    end

    describe "with valid information" do
      let(:new_email)  { "NewEmail1@nexuscafe.com" }

      before do
#        save_and_open_page
        fill_in EMAIL_LABEL,             with: new_email
        click_button CHANGE_EMAIL_BUTTON 
      end

      it { should have_content('Email has been changed') }
      if CONFIG[:verify_email?]
        it { should have_title('Verify Email Address') }
      else
        it { should have_title('Edit user') }
      end
      specify { expect(reload_obj(user).email).to  eq new_email.downcase! }
    end
  end 

  if CONFIG[:enable_username?]  
    describe "change username" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
        visit edit_username_path(user)
      end

      describe "page" do
        it { should have_content("Change Username") }
        it { should have_title("Change Username") }
      end

      describe "with invalid information" do

        describe "username blank" do
          before do 
            fill_in USERNAME_LABEL, with: " "
            click_button CHANGE_USERNAME_BUTTON 
          end

          it { should have_content('error') }
        end

        describe "username too short" do
          before do 
            fill_in USERNAME_LABEL, with: "a"
            click_button CHANGE_USERNAME_BUTTON 
          end

          it { should have_content('error') }
          it { should have_content('Username is too short') }
        end

        describe "username too long" do
          before do 
            fill_in USERNAME_LABEL, with: "a"*(User::USERNAME_MAX_LENGTH + 1)
            click_button CHANGE_USERNAME_BUTTON 
          end

          it { should have_content('error') }
          it { should have_content('Username is too long') }
        end

        describe "invalid character in username" do
          before do 
            fill_in USERNAME_LABEL, with: "foo@bar"
            click_button CHANGE_USERNAME_BUTTON 
          end

          it { should have_content('error') }
          it { should have_content('Username is invalid') }
        end
      end

      describe "with valid information" do
        let(:new_name)  { "NewUserName" }

        before do
  #        save_and_open_page
          fill_in USERNAME_LABEL,             with: new_name
          click_button CHANGE_USERNAME_BUTTON 
        end

        it { should have_content('Username has been changed') }
        it { should have_title('Edit user') }
        specify { expect(reload_obj(user).username).to  eq new_name.downcase }
      end
    end  
  end #if CONFIG[:enable_username?]

  describe "When signed in" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user, no_capybara: true
    end

    describe "get new user" do
      before do
      	get new_user_path
      end	 
      specify { expect(response).to redirect_to(root_path) }
    end

  end
end  

