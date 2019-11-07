# frozen_string_literal: true

require 'pathname'
require 'java_buildpack/util'
require 'java_buildpack/logging/logger_factory'
require 'yaml'

module JavaBuildpack
  module Util

    # Utility for loading "components.yml" configuration
    class ConfigurationUtilsForWAS

      private_class_method :new

      class << self
        # Loads a components configuration file from the buildpack configuration directory.
        # If the configuration file does not exist, returns an empty hash.
        # Overlays configuration in a matching environment variable, on top of the loaded
        # configuration, if present. Will not add a new configuration key where an existing one does not exist.
        #
        # @param [pathname] file the file of the components configuration
        # @param [Hash of Array] user_provided the environment value presented by user like 'JBP_CONFIG_COMPONENTS'
        # @param [Boolean] should_log whether the contents of the configuration file should be logged.  This value
        #                             should be left to its default and exists to allow the logger to use the utility.
        # @return [Hash] the configuration or an empty hash if the configuration file does not exist
        def load_components_configuration(file, user_provided, should_log, is_packaging)
          configuration = YAML.load_file(file)
#          logger.info { "Configuration from #{file}: #{configuration}: #{is_packaging}" } if should_log
          if user_provided
             user_provided_container_value = find_env_value(user_provided, CONTAINERS_COMP_KEYNAME)
             logger.info { "user_provided_container_value :  #{user_provided_container_value}" }
             configuration.each do |components_key, components_value|
               next unless components_key.eql? CONTAINERS_COMP_KEYNAME
#              logger.info { "components_key : #{components_key}" }
#              logger.info { "components_value : #{components_value} " }
               if user_provided_container_value.eql? 'Jboss'
                 do_resolve_two_containers_problem(configuration, CONTAINERS_COMP_KEYNAME)
               elsif user_provided_container_value.eql? 'Tomcat'
                 find_idx = components_value.index(CONTAINER_JBOSS_CLASSNAME)
                 do_delete_jboss_container(configuration, find_idx)
               end
             end  
          else

          end

          configuration
        end

        private

        CONTAINERS_COMP_KEYNAME = 'containers'
        CONTAINER_JBOSS_CLASSNAME = 'JavaBuildpack::Container::Jboss'
        CONTAINER_TOMCAT_CLASSNAME = 'JavaBuildpack::Container::Tomcat'
        FRAMEWORK_SPRING_AUTO_RECONFIG_CLASSNAME = 'JavaBuildpack::Framework::SpringAutoReconfiguration'

        private_constant :CONTAINERS_COMP_KEYNAME, :CONTAINER_JBOSS_CLASSNAME, :CONTAINER_TOMCAT_CLASSNAME,
                         :FRAMEWORK_SPRING_AUTO_RECONFIG_CLASSNAME
        def find_env_value(user_provided, components_key)
          user_provided_value = YAML.safe_load(user_provided)
          user_provided_value.each do |value|
            return value[components_key] if value.key? components_key
          end
        end

        def do_resolve_component_value(origin_val, resolve_val)
          return origin_val if origin_val.include?(resolve_val)

          origin_val = origin_val.slice(0..origin_val.rindex(':')) + resolve_val
          return origin_val unless origin_val.include?(resolve_val)
        end

        def do_resolve_load_spring_auto_reconfiguration(configuration, component_name)
          return unless configuration[component_name].index(CONTAINER_JBOSS_CLASSNAME)

          do_delete_loaded_component(configuration, component_name, CONTAINER_JBOSS_CLASSNAME,
                                     'frameworks', FRAMEWORK_SPRING_AUTO_RECONFIG_CLASSNAME)
        end

        def do_delete_jboss_container(configuration, index)
          return configuration[CONTAINERS_COMP_KEYNAME].delete_at(index)
        end

        def do_delete_loaded_component(components, flag_key, flag_component, delete_key, delete_component)
          flag_comp_idx = components[flag_key].index(flag_component)
          delete_comp_idx = components[delete_key].index(delete_component)

          return unless flag_comp_idx && delete_comp_idx

          components[delete_key].delete_at(delete_comp_idx)
        end

        def do_resolve_two_containers_problem(configuration, component_name)
          return unless configuration[component_name].index(CONTAINER_TOMCAT_CLASSNAME)

          do_delete_loaded_component(configuration, component_name, CONTAINER_TOMCAT_CLASSNAME,
                                     CONTAINERS_COMP_KEYNAME, CONTAINER_TOMCAT_CLASSNAME)
        end

        def logger
          JavaBuildpack::Logging::LoggerFactory.instance.get_logger ConfigurationUtilsForWAS
        end

      end
    end
  end
end
