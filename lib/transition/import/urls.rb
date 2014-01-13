require 'csv'

module Transition
  module Import
    class Urls
      def self.from_csv!(site_abbr, filename)
        site = Site.find_by_site!(site_abbr)
        logger, logfilename = new_logger(site)
        logger.info "Importing site urls for #{site.organisation.title} - #{site.site}"
        successes, failures, existing = 0, 0, 0
        failure_messages = []
        begin
          CSV.foreach(filename, :headers => true , :encoding => 'ISO-8859-1') do |row|          
            if (Url.find_by_url(row["Url"]))
              existing += 1
            else
              new_url = Url.new(
                :url => row["Url"],
                :title => row["Title"],
                :site => site)
              if (new_url.save rescue false) 
                successes += 1
                logger.info ("Url #{row["Url"]} added")
              else
                failures += 1
                logger.error "#{new_url.errors.messages.inspect}: #{row.inspect}"
              end
            end          
          end
          logger.info "Urls - #{successes} successfully imported, #{failures} failed, #{existing} previously imported."
        rescue Exception => e
          logger.error "Upload failed - #{e.to_s}"
        end
        logger.close
        logfilename
      end

      def self.new_logger(site)
        FileUtils.mkdir_p Rails.root.join('log', 'import_urls')
        logfilename = "#{site.site.gsub(' ', '_')}-#{Time.now.strftime('%Y%m%d-%H:%M:%S')}-#{rand(1...100).to_s}.log"
        logger = AuditLogger.new(Rails.root.join('log', 'import_urls', logfilename), 'Import urls')
        [logger, logfilename]
      end
    end
  end
end
