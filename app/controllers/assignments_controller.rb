class AssignmentsController < ApplicationController
  
  def index
    @uopuser = Uopuser.find_by_id(params[:uopuser_id])
    @assignments = @uopuser.assignments
    @statuses = [:new, :review, :updating, :updated, :ignore, :migrated]
  end
  
end