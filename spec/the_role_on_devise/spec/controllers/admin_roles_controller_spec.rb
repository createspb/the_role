require 'spec_helper'

describe Admin::RolesController do
  describe "Admin Section" do
    describe 'Unauthorized' do
      before(:each) do
        @role = FactoryGirl.create(:role_user)
      end

      %w{ index new }.each do |action|
        it action.upcase do
          get action
          response.should redirect_to new_user_session_path
        end
      end

      %w{ edit update create destroy }.each do |action|
        it action.upcase do
          get action, { id: @role.id }
          response.should redirect_to new_user_session_path
        end
      end
    end

    describe "Authorized / Regular user" do
      describe "Can't do something with Roles" do
        before(:each) do
          @user = FactoryGirl.create(:user)
          @role = FactoryGirl.create(:role_user)
          sign_in @user
        end

        %w{ index new }.each do |action|
          it action.upcase do
            get action
            response.body.should match access_denied_match
          end
        end

        %w{ edit update create destroy }.each do |action|
          it action.upcase do
            get action, { id: @role.id }
            response.body.should match access_denied_match
          end
        end
      end
    end

    describe "Creating of role" do
      before(:each) do
        @admin_role = FactoryGirl.create(:admin)
        @admin      = FactoryGirl.create(:user, role: @admin_role)
        sign_in @admin
      end

      it "Validation errors on create" do
        Role.count.should eq 1
        post :create, { role: { wrong_param: 1 } }

        Role.count.should eq 1
        expect(response).to render_template :new
      end

      it "Success create" do
        Role.count.should eq 1
        post :create, { role: { name: :test, title: :test, description: :test } }

        Role.count.should eq 2
        Role.last.admin?.should be_false
      end

      it "Success create based on Admin" do
        Role.count.should eq 1
        post :create, { role: { name: :test, title: :test, description: :test }, based_on: @admin_role.id }

        Role.count.should eq 2
        Role.last.admin?.should be_true
      end
    end
  end
end