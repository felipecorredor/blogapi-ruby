# Status Rails handles status codes
# https://ieftimov.com/posts/how-rails-handles-status-codes/

class HealthController < ApplicationController
  def health 
    render json: {api: 'OK'}, status: :ok 
  end
end