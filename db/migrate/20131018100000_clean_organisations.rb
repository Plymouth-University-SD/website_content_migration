class CleanOrganisations < ActiveRecord::Migration
  def change
    Organisation.all.each do |org|
      org.destroy
      
    end
  end  
end