require 'rails_helper'

RSpec.describe "Applications", type: :request do

  let(:user) { create(:user) }
  before { sign_in_as(user) }

  describe "GET /applications" do
    it "returns http success" do
      get applications_path
      expect(response).to be_success_with_view_check('index')
    end
  end

  describe "GET /applications/:id" do
    let(:application_record) { create(:application) }


    it "returns http success" do
      get application_path(application_record)
      expect(response).to be_success_with_view_check('show')
    end
  end


end
