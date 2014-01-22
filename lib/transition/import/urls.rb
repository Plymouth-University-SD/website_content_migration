# encoding: UTF-8
require 'csv'
require 'uri'

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
            if (Url.find_by_url(URI.escape(row["Url"])))
              existing += 1
            else
              new_url = Url.new(
                :url => URI.escape(row["Url"]),
                :title => clean(row["Title"]),
                :site => site)
              if (new_url.save rescue false) 
                successes += 1
                logger.info ("Url #{URI.escape(row["Url"])} added")
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

      def self.clean(text)
        # http://stackoverflow.com/questions/1268289/how-to-get-rid-of-non-ascii-characters-in-ruby
        encoding_options = {
          :invalid           => :replace,  # Replace invalid byte sequences
          :undef             => :replace,  # Replace anything not defined in ASCII
          :replace           => '',        # Use a blank for those replacements
          :universal_newline => true       # Always break lines with \n
        }
        text.encode Encoding.find('ASCII'), encoding_options
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
