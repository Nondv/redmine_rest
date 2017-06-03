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
    class << self
      attr_accessor :sub_url
    end
    def self.collection_path(prefix_options = {}, query_options = nil)
      if (self.sub_url) then
        check_prefix_options(prefix_options)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "/#{self.sub_url}#{prefix(prefix_options)}#{collection_name}.#{format.extension}#{query_string(query_options)}"
      else
        check_prefix_options(prefix_options)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}.#{format.extension}#{query_string(query_options)}"
      end
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

    require 'uri'    
    #
    # Class for self-methods. Dont use it outside this module
    #
    class ModelConfigurator
      def configure_models(params)
        uri = URI.parse(params[:site])
        site = uri.scheme+'://'+uri.host || Issue.site
        if (uri.port) then
          site += ":" + uri.port.to_s
        end
        site += '/'
        sub_url = uri.path
        user = user_for_models(params)
        password = params.key?(:password) ? params[:password] : Issue.password

        change_models_params site: site,
          user: user,
          password: password,
          sub_url: sub_url
      end

      private

      def change_models_params(params)
        Models::LIST.each do |m|
          m.site = params[:site]
          m.sub_url = params[:sub_url]
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
