require 'active_resource'

Dir[File.expand_path('../models/*.rb', __FILE__)].each { |f| require f }

module ActiveResource
  #
  # some monkey-patching
  #
  class Base
    def self.find_by_id(id)
      find(id)
    rescue ActiveResource::ResourceNotFound
      nil
    end
  end
end

module RedmineRest
  #
  # Namespace for models + some self-methods
  #
  module Models
    LIST = constants
           .map { |symbol| const_get(symbol) }
           .find_all { |const| const.is_a?(Class) && const < ActiveResource::Base }
           .freeze

    def self.configure_models(params)
      ModelConfigurator.new.configure_models(params)
    end

    #
    # Class for self-methods. Dont use it outside this module
    #
    class ModelConfigurator
      def configure_models(params)
	print("++++++++++++++"+params.to_s)
        site = params[:site] || Issue.site
        user = user_for_models(params)
        password = params.key?(:password) ? params[:password] : Issue.password

        change_models_params site: site,
                             user: user,
                             password: password
      end

      private

      def change_models_params(params)
        Models::LIST.each do |m|
	print("+++site ++"+m.site+" ++++"+params[:site]+"+++++"+params.to_s)
          m.site = params[:site]
          m.user = params[:user]
          m.password = params[:password]
        end
      end

      def user_for_models(params)
        fail(ArgumentError, 'user + apikey was given') if params[:user] && params[:apikey]
        params[:user] || params[:apikey] || Issue.user
      end
    end
  end
end
