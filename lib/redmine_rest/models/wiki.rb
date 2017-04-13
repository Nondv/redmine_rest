require 'active_resource'

require_relative 'user'
require_relative 'project'
require_relative 'version'
require_relative 'relation'
require_relative 'tracker'
require_relative 'attachment'
require_relative 'collections/base'

module RedmineRest
  module Models
    #
    # wiki model
    #
    class Wiki < ActiveResource::Base
      self.format = :xml
      self.collection_parser = Collections::Base

      has_one :author, class_name: User
      has_one :project, class_name: Project
      has_one :parent, class_name: Wiki
      has_many :children, class_name: Wiki

      validates :title, :project_id, presence: true

      def project_id
        attributes[:project_id] || project? && project.id
      end

      #
      # Adds children to request.
      #      #
      def self.find(what, options = {})
        options[:params] = {} unless options[:params]
        params = options[:params]

        if params[:include]
          params[:include] += ',children'
        else # doubling is not bad
          params[:include] = 'children'
        end

        super(what, options)
      end

      #
      # Sets #project_id via Project object.
      #
      def project=(project)
        fail ArgumentError unless project.is_a? Project
        self.project_id = project.id
      end

      #
      # Sets #parent_wiki_id via Wiki object
      #
      def parent=(wiki)
        fail ArgumentError unless wiki.is_a? Wiki
        self.parent_wiki_id = wiki.id
      end

      def method_missing(method, *args)
        return super if block_given? || method.to_s.end_with?('?') || !args.empty?
        attributes[method]
      end
    end
  end
end