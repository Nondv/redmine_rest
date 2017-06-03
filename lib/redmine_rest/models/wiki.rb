require 'active_resource'

require_relative 'collections/base'
require_relative 'user'

module RedmineRest
  module Models
    #
    # Wiki model
    #
    class Wiki < ActiveResource::Base
      self.format = :xml
      self.collection_parser = Collections::Base
      self.prefix = '/projects/:project_id/'

      has_one :author, class_name: User
      
      validates :title, presence: true
            
      #
      # Overrides parent method.
      # When we want to fetch one wiki, we need not to use prefix
      #
      def self.collection_path(prefix_options = {}, query_options = nil)
        if (self.sub_url) then
          check_prefix_options(prefix_options)
          prefix_options, query_options = split_options(prefix_options) if query_options.nil?
          "/#{self.sub_url}#{prefix(prefix_options)}wiki/index.#{format.extension}#{query_string(query_options)}"
        else
          check_prefix_options(prefix_options)
          prefix_options, query_options = split_options(prefix_options) if query_options.nil?
          "#{prefix(prefix_options)}wiki/index.#{format.extension}#{query_string(query_options)}"
        end
      end
      
      def self.element_path(title, prefix_options = {}, query_options = nil)
        if (self.sub_url) then
          check_prefix_options(prefix_options)
          prefix_options, query_options = split_options(prefix_options) if query_options.nil?
          "/#{self.sub_url}#{prefix(prefix_options)}wiki/#{URI.parser.escape title}.#{format.extension}#{query_string(query_options)}"
        else
          check_prefix_options(prefix_options)
          prefix_options, query_options = split_options(prefix_options) if query_options.nil?
          "#{prefix(prefix_options)}wiki/#{URI.parser.escape title}.#{format.extension}#{query_string(query_options)}"
        end        
      end
    end
  end
end
