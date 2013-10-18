class CleanSites < ActiveRecord::Migration
  def change
    Site.all.each do |site|
      site.urls.all.each do |url|
        url.destroy
      end
      site.destroy      
    end
  end  
end