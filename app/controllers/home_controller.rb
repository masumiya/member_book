class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  def index
    # do something
  end
end
