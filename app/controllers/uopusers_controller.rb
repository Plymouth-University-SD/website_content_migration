class UopusersController < ApplicationController
  
  def index
    @uopusers = Uopuser.all
  end
  
  def show
    @uopuser = Uopuser.find_by_id(params[:id])
  end
  
  def new
    @uopuser = Uopuser.new
  end
  
  def create
    @uopuser = Uopuser.new(params[:uopuser])

    
      if @uopuser.save
        redirect_to @uopuser, notice: 'User was successfully created.' 
      else
        render action: "new" 
      end
   
  end
  
end