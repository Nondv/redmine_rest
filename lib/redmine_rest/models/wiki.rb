require 'active_resource'

require_relative 'collections/base'
require_relative 'user'
require_relative 'project'

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
      has_one :project, class_name: Project
      
      validates :title, :tracker_id, presence: true
      
      #
      # Sets #project_id via Project object.
      #
      def project=(project)
        fail ArgumentError unless project.is_a? Project
        self.project_id = project.id
      end
      
      #
      # Overrides parent method.
      # When we want to fetch one wiki, we need not to use prefix
      #
      def self.collection_path(prefix_options = {}, query_options = nil)
        check_prefix_options(prefix_options)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}wiki/index.#{format.extension}#{query_string(query_options)}"
      end
    end
  end
end
