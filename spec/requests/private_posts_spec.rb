require "rails_helper"
require "byebug"

RSpec.describe "Posts with authentication", type: :request do

  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  
  let!(:user_post) { create(:post, user_id: user.id) }
  let!(:other_user_post) { create(:publised_post, user_id: other_user.id) }
  let!(:other_user_post_draf) { create(:post, user_id: other_user.id, publised: false) }

  let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}" } }
  let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}" } }

  let!(:create_params) { { "post" => { "title" => "title", "content" => "content", "publised" => true } } }
  
  let!(:update_params) { { "post" => { "title" => "title", "content" => "content", "publised" => true } } }

  describe "GET /posts/{id}" do
    context "with valid auth" do 
      context "when requisiting other's author post" do
        context "When post is public" do
          before { get "/posts/#{other_user_post.id}", headers: auth_headers }
          # payload
          context "payload" do 
            subject { payload }
            it { is_expected.to include(:id) }
          end
          # response
          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end
        end

        context "When post is draft" do
          before { get "/posts/#{other_user_post_draf.id}", headers: auth_headers }
          # payload
          context "payload" do 
            subject { payload }
            it { is_expected.to include(:error) }
          end
          # response
          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:not_found) }
          end
        end

      end

      context "when requisiting user's post" do    
      end
    end
  end


  describe "POST /posts" do
    # with auth -> create
    context "with valid auth" do
      before {  post "/posts", params: create_params, headers: auth_headers }
      # payload
      context "payload" do 
        subject { payload }
        it { is_expected.to include(:id, :title, :content, :publised, :author) }
      end
      # response
      context "response" do
        subject { response }
        it { is_expected.to have_http_status(:created) }
      end
    end

    context "without auth" do
      before {  post "/posts", params: create_params }
      # payload
      context "payload" do 
        subject { payload }
        it { is_expected.to include(:error) }
      end
      # response
      context "response" do
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end

    # without auth -> !create -> 401

  end

  describe "PUT /posts" do
    # with auth ->
      # update own posts
      # cannon't update others posts -> 401
    context "with valid auth" do

      context "when updating user's post" do

        before {  put "/posts/#{user_post.id}", params: update_params, headers: auth_headers }

        # payload
        context "payload" do 
          subject { payload }
          it { is_expected.to include(:id, :title, :content, :publised, :author) }
          it { expect(payload[:id]).to eq(user_post.id) }
        end
        # response
        context "response" do
          subject { response }
          it { is_expected.to have_http_status(:ok) }
        end
      end


    end  
    # withouth auth ->
      # !update post -> 401
    context "withouth valid auth" do

      context "when updating user's post" do  
        before {  put "/posts/#{user_post.id}", params: update_params, headers: auth_headers }
        # payload
        context "payload" do 
          subject { payload }
          it { is_expected.to include(:id, :title, :content, :publised, :author) }
          it { expect(payload[:id]).to eq(user_post.id) }
        end
        # response
        context "response" do
          subject { response }
          it { is_expected.to have_http_status(:ok) }
        end
      end

      context "when updating other user's post" do
        before {  put "/posts/#{other_user_post.id}", params: update_params, headers: auth_headers }
        # payload
        context "payload" do 
          subject { payload }
          it { is_expected.to include(:error) }
        end
        # response
        context "response" do
          subject { response }
          it { is_expected.to have_http_status(:not_found) }
        end
      end
    end 
  end

  private

  def payload
    JSON.parse(response.body).with_indifferent_access
  end
end