class UrlsController < ApplicationController

  include UrlsHelper
  URL_FILTER_QUERY_TO_STATE = {'updating' => 'updating', 'updated' => 'updated', 'ignore' => 'ignore', 'migrated' => 'migrated'}

  before_filter :find_site

  def index
    @urls = url_filter(@site.urls)
    @uopusers = Uopuser.all
    flash.now[:error] = 'No Urls were found' if @urls.count == 0
  end

  def show
    #@urls = url_filter(@site.urls)
    @url = Url.find(params[:id])
    if @url.nil?
      @url = url_filter(@site.urls).first
      redirect_to site_url_path(@site, @url,  url_filter_hash) and return if @url
    end
    @last_saved_url = @site.urls.find(params[:last_saved_url]) if params[:last_saved_url].present?
    flash.now[:error] = 'No Urls were found' if @url.nil?
  end

  def update
    destiny = params[:destiny].try(:to_sym)
    @url = @site.urls.find(params[:id])

    # update @url and any other urls that have been selected, with the same values
    selected_urls = [@url]
    selected_urls += @site.urls.find(params[:url_select].keys) if params[:url_select].present?
    Url.transaction do
      selected_urls.each do |url|
        url.state = destiny if destiny
        url.for_scraping = nil if params[:url] && params[:url][:for_scraping].nil?
      end
      if selected_urls.all? {|url| url.update_attributes(params[:url]) }
        #redirect_to site_url_path(@url.site, @url.next(url_filter(@site.urls)), url_filter_hash.merge(last_saved_url: @url.id)) and return
        redirect_to uopuser_assignments_path(@url.assignment.uopuser_id, url_filter_hash.merge(last_saved_url: @url.id)) and return
      else
        @urls = url_filter(@site.urls)
        raise ActiveRecord::Rollback
      end
    end
    render 'show'
  end

  protected

  def url_filter(urls)
    urls = urls.where(state: URL_FILTER_QUERY_TO_STATE[params[:state]]) if params[:state].present?
    urls = urls.where(for_scraping: params[:for_scrape] == 'true') if params[:for_scrape].present?
    if params[:q].present? then
      urls = urls.where("url like ?", "%#{params[:q]}%") if params[:search_by] == 'url'
      urls = urls.where("title like ?", "%#{params[:q]}%") if params[:search_by] == 'title'
    end
    urls = urls.order(params[:sort_by]) if params[:sort_by].present?
    urls
  end
end
