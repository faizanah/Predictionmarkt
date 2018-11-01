class BlogController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :initialize_posts
  before_action :initialize_categories

  include BlogHelper

  BLOG_CONFIG = Rails.application.config_for(:blog).with_indifferent_access.freeze

  respond_to :html, :js

  def index
    @page_title = 'Blog'
    @sorted_posts = @post_configs.values.sort_by { |p| p['date'] }.reverse
  end

  def show
    @post_config = post_config(params[:id])
    if @post_config
      @page_title = @post_config[:title]
      redirect_to current_post_path unless valid_uri?
    else
      render status: 404, text: ''
    end
  end

  def subscribe
    @form = SubscribeForm.new(subscribe_form_params)
    @form.save
    render text: 'ok'
  end

  private

    def post_config(blog_id)
      post_config = BLOG_CONFIG[:posts][blog_id.to_i]
      return nil unless post_config
      post_config.merge(id: blog_id.to_i).with_indifferent_access
    end

    def valid_uri?
      params[:title] == blog_post_uri(@post_config)
    end

    def current_post_path
      blog_post_path_from_config(@post_config)
    end

    def initialize_posts
      @post_configs = BLOG_CONFIG[:posts].map { |k, v| [k, post_config(k)] }.to_h
    end

    def initialize_categories
      @ico_category = MarketCategory.where(name: 'ICOs').first
    end

    def subscribe_form_params
      params.fetch(:subscribe_form, {}).permit(:email)
    end
end
