require 'action_dispatch/routing/route_set'

module ActionDispatch
  module Routing
    class RouteSet #:nodoc:
      # Known Issue: Monkey-patching `url_for` is error-prone.
      # For example, in rails 4.2, the method signature changed from
      #
      #     def url_for(options)
      #
      # to
      #
      #     def url_for(options, route_name = nil, url_strategy = UNKNOWN)
      #
      # Is there an alternative design using composition or class
      # inheritance?

      def url_for_with_subdomains(options, *args)
        if SubdomainFu.needs_rewrite?(options[:subdomain], (options[:host] || @request.host_with_port)) || options[:only_path] == false
          options[:only_path] = false if SubdomainFu.override_only_path?
          options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || @request.host_with_port)
          # puts "options[:host]: #{options[:host].inspect}"
        else
          options.delete(:subdomain)
        end
        url_for_without_subdomains(options, *args)
      end
      alias_method_chain :url_for, :subdomains
    end
  end
end
