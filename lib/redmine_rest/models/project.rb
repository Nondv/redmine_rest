require 'active_resource'

require_relative 'tracker'
require_relative 'collections/base'
require_relative 'version'
require_relative 'membership'
require_relative 'wiki'

module RedmineRest
  module Models
    #
    # Project model
    #
    class Project < ActiveResource::Base
      self.format = :xml
      self.collection_parser = Collections::Base

      has_many :trackers, class_name: Tracker

      #
      # Adds trackers to request.
      #
      def self.find(scope, options = {})
        options[:params] = {} unless options[:params]
        params = options[:params]

        if params[:include]
          params[:include] += ',trackers'
        else # doubling is not bad
          params[:include] = 'trackers'
        end

        super(scope, options)
      end

      def versions
        Version.all params: { project_id: id }
      end

      def memberships
        Membership.all params: { project_id: id }
      end

      def wikis
        Wiki.all params: { project_id: id }
      end

      def members(options = {})
        users = memberships
                .map { |m| m.user? ? m.user : m.group.reload.users }
                .flatten
        users.map(&:reload) if options[:reload]

        Collections::Base.new(users)
      end
    end
  end
end
