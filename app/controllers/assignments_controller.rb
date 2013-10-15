class AssignmentsController < ApplicationController
  
  include AssignmentsHelper
  
  def index
    if params[:unassign].present?
      selection = params[:url_select]
      selection.each do |sel|
        a = Assignment.delete(sel[0])
        url = Url.find_by_id(sel[1])
        url.state = 'new'
        url.save
      end
    end      
    @uopuser = Uopuser.find_by_id(params[:uopuser_id])
    @assignments = @uopuser.assignments
    @statuses = [:review, :updating, :updated, :ignore, :migrated]
  end
  
  def new
      @sites = Site.all
      if params[:site].present?
        @site = Site.find_by_id(params[:site]) 
        @urls = url_filter(@site.urls)
        flash.now[:error] = 'No Urls were found' if @urls.count == 0
      end
      @uopuser = Uopuser.find_by_id(params[:uopuser_id])
      @assignments = @uopuser.assignments
      @statuses = [:review, :updating, :updated, :ignore, :migrated]
  end
  
  def create
    @uopuser = Uopuser.find_by_id(params[:uopuser_id])
    @assignments = @uopuser.assignments
    selection = params[:url_select]
    selection.each do |sel|
      a = Assignment.create!(uopuser_id: @uopuser.id, url_id: sel[0])
      url = Url.find_by_id(sel[0])
      url.state = 'review'
      url.save
    end
    redirect_to uopuser_assignments_path
  end
  
  protected
  
  def url_filter(urls)
    urls = urls.where(state: 'new')
    if params[:q].present? then
      urls = urls.where("url like ?", "%#{params[:q]}%") if params[:search_by] == 'url'
      urls = urls.where("title like ?", "%#{params[:q]}%") if params[:search_by] == 'title'
    end
    urls = urls.order(params[:sort_by]) if params[:sort_by].present?
    urls    
  end  
    
end