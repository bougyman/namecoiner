module Namecoiner
  class NewsController < Ramaze::Controller
    map '/news'
    layout :main

    def index
      @articles = News
    end
  end
end
