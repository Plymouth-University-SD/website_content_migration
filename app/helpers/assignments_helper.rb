module AssignmentsHelper
  
  def options_for_sites_select(sites, site)
    options = []
    sites.each do |s|
      options << [s.site, s.id]
    end
    if site.nil?
      selected = nil
    else
      selected = site.id
    end
    options_for_select(options, selected)
  end
  
end