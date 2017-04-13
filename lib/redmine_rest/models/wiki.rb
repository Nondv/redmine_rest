require 'active_resource'

require_relative 'collections/base'
require_relative 'user'
require_relative 'group'

module RedmineRest
  module Models
    #
    # Wiki model
    #
    class Wiki < ActiveResource::Base
      self.format = :xml
      self.collection_parser = Collections::Base
      self.prefix = '/projects/:project_id/'

      #
      # Overrides parent method.
      # When we want to fetch one wiki, we need not to use prefix
      #
      def self.element_path(title, _prefix_options = {}, query_options = nil)
        self.prefix+"wiki/#{URI.parser.escape title.to_s}#{format_extension}#{query_string(query_options)}"
      end
      def self.collection_path(title, _prefix_options = {}, query_options = nil)
        self.prefix+"wiki/index#{format_extension}#{query_string(query_options)}"
      end      
    end
  end
end
