require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'

module Predictit
  class Crawler
    attr_accessor :session

    include Capybara::DSL
    TRENDING = "https://www.predictit.org/Browse/Trending".freeze
    MOSTPREDICTED = "https://www.predictit.org/Browse/MostPredicted".freeze

    def initialize
      @session = Capybara::Session.new(:chrome)
    end

    def get_trending_ids
      @session.visit TRENDING
      b = @session.all('a')
      b.map{ |c| c['href']}.grep(/Market/) { |a| a.scan(/\d+/).first.to_i }.uniq
    end

    def get_mostpredicted_ids
      @session.visit MOSTPREDICTED
      b = @session.all('a')
      b.map{ |c| c['href']}.grep(/Market/) { |a| a.scan(/\d+/).first.to_i }.uniq
    end
  end
end
