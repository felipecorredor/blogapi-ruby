require "rails_helper"
require "byebug"

RSpec.describe "Posts", type: :request do
  describe "GET /post" do
  
    it "should return OK" do
      get '/posts'
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(:ok)
    end


    describe "Search" do
      let!(:best_rails) { create(:publised_post, title: 'Best Ruby on Rails') }
      let!(:hello_rails) { create(:publised_post, title: 'Hello Rails') }
      let!(:hello_world) { create(:publised_post, title: 'Hello World') }

      it "should filter posts by title" do
        get '/posts?search=Hello'
        payload = JSON.parse(response.body)
        expect(payload).to_not be_empty
        expect(payload.size).to eq(2)
        expect(payload.map { |p| p["id"] }.sort).to eq([hello_rails.id, hello_world.id].sort)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "with data in the DB" do
    # let!  solo se va a evuluar cuando se haga referencia a la variable
    # RSpec       Factorybot
    let!(:posts) { create_list(:post, 10, publised: true) }

    it "should return all publised posts" do
      get "/posts"
      payload = JSON.parse(response.body)
      expect(payload.size).to eq(posts.size)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /post/{id}" do
    # RSpec     Factorybot
    let!(:post) { create(:post) }
    
    it "should return a post" do
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)

      expect(payload).to_not be_empty
      expect(payload["id"]).to eq(post.id)
      expect(payload["title"]).to eq(post.title)
      expect(payload["content"]).to eq(post.content)
      expect(payload["publised"]).to eq(post.publised)
      expect(payload["author"]["name"]).to eq(post.user.name)
      expect(payload["author"]["email"]).to eq(post.user.email)
      expect(payload["author"]["id"]).to eq(post.user.id)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /posts" do
    let!(:user) { create(:user) }
    
    it "should create a post" do
      req_payload = {
        post: {
          title: 'Title',
          content: 'Content',
          publised: false,
          user_id: user.id
        }
      }
      # POST HTTP method
      post "/posts", params: req_payload

      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["id"]).to_not be_nil
      expect(payload["title"]).to eq('Title')
      expect(response).to have_http_status(:created)
    end

    it "should return error message on invalid post" do

      req_payload = {
        post: {
          content: 'Content',
          publised: false,
          user_id: user.id
        }
      }
      # POST HTTP method
      post "/posts", params: req_payload

      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["error"]).to_not be_empty
      expect(response).to have_http_status(:unprocessable_entity)
   
    end
  end

  describe "PUT /posts/{id}" do
    let!(:article) { create(:post) }
    it "should update a post" do
    
      req_payload = {
        post: {
          title: 'Title',
          content: 'Content',
          publised: true
        }
      }
      
      # POST HTTP method
      put "/posts/#{article.id}", params: req_payload

      payload = JSON.parse(response.body)
      # byebug
      expect(payload).to_not be_empty
      expect(payload["id"]).to eq(article.id)
      expect(response).to have_http_status(:ok)
    end

    it "should return error message on invalid updated post" do

      req_payload = {
        post: {
          title: nil,
          content: nil,
          publised: false
        }
      }
      # POST HTTP method
      put "/posts/#{article.id}", params: req_payload

      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["error"]).to_not be_empty
      expect(response).to have_http_status(:unprocessable_entity)
   
    end
  end
end
