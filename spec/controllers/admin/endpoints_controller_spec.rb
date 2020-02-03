# frozen_string_literal: true

require "spec_helper"

module Decidim::ComparativeStats::Admin
  describe EndpointsController, type: :controller do
    routes { Decidim::ComparativeStats::AdminEngine.routes }

    let(:user) { create(:user, :confirmed, :admin, organization: organization) }
    let(:organization) { create(:organization) }
    let(:url) { "http://example.com/api" }
    let(:endpoint) { create :endpoint, endpoint: url, organization: organization }
    let(:active) { true }
    let(:form) do
      {
        endpoint: endpoint.endpoint,
        name: "Test name",
        active: active
      }
    end
    let(:version) { "0.19.test" }
    let(:data) { { decidim: { applicationName: "Decidim test", version: version } } }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user

      controller.params["endpoint"] = form
      controller.api.client = Graphlient::Client.new(url, schema_path: "#{__dir__}/../../lib/schema.json")
      stub_request(:post, url)
        .to_return(status: 200, body: "{\"data\":#{data.to_json}}", headers: {})
    end

    describe "GET #index" do
      it "renders the index listing" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(subject).to render_template(:index)
      end
    end

    describe "GET #new" do
      it "renders the empty form" do
        get :new
        expect(response).to have_http_status(:ok)
        expect(subject).to render_template(:new)
      end
    end

    describe "POST #create" do
      context "when there is permission" do
        it "returns ok" do
          post :create, params: { endpoint: form }
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end

        it "creates the new endpoint" do
          post :create, params: { endpoint: form }
          expect(Decidim::ComparativeStats::Endpoint.first.name).to eq(endpoint.name)
        end
      end
    end

    describe "GET edit" do
      let!(:endpoint) { create :endpoint, name: "Some name", endpoint: url, organization: organization }

      it "renders the edit form" do
        get :edit, params: { id: endpoint.id }
        expect(response).to have_http_status(:ok)
        expect(subject).to render_template(:edit)
      end
    end

    describe "PATCH #update" do
      context "when there is permission" do
        let!(:endpoint) { create :endpoint, name: "Some name", endpoint: url, organization: organization }

        it "returns ok" do
          patch :update, params: { id: endpoint.id, endpoint: form }
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end

        it "creates the new endpoint" do
          patch :update, params: { id: endpoint.id, endpoint: form }
          expect(Decidim::ComparativeStats::Endpoint.first.name).to eq(form[:name])
        end
      end
    end
  end
end
