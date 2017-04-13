require 'active_resource'

require_relative 'collections/base'
require_relative 'user'
require_relative 'group'

module RedmineRest
  module Models
    #
    # Membership model
    #
    class Membership < ActiveResource::Base
      self.format = :xml
      self.collection_parser = Collections::Base
      self.prefix = '/projects/:project_id/'

      has_one :user, class_name: User
      has_one :group, class_name: Group

      #
      # Overrides parent method.
      # When we want to fetch one membership, we need not to use prefix
      #
      def self.element_path(id, _prefix_options = {}, query_options = nil)
        "/memberships/#{URI.parser.escape id.to_s}#{format_extension}#{query_string(query_options)}"
      end
    end
  end
end
