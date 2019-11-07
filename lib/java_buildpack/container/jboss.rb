# frozen_string_literal: true

# Cloud Foundry Java Buildpack
# Copyright 2013-2019 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/container'
require 'java_buildpack/util/java_main_utils'

module JavaBuildpack
  module Container

    # Encapsulates the detect, compile, and release functionality for applications running Spring Boot CLI
    # applications.
    class Jboss < JavaBuildpack::Component::VersionedDependencyComponent

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        download_tar
        update_configuration
        copy_application
        copy_additional_libraries
        create_dodeploy
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        @droplet.environment_variables.add_environment_variable 'JAVA_OPTS', '$JAVA_OPTS'
        @droplet.java_opts
                .add_system_property('jboss.http.port', '$PORT')
                .add_system_property('java.net.preferIPv4Stack', true)
                .add_system_property('java.net.preferIPv4Addresses', true)

        [
          @droplet.environment_variables.as_env_vars,
          @droplet.java_home.as_env_var,
          'exec',
          "$PWD/#{(@droplet.sandbox + 'bin/standalone.sh').relative_path_from(@droplet.root)}",
          '-b',
          '0.0.0.0'
        ].compact.join(' ')
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        web_inf? && !JavaBuildpack::Util::JavaMainUtils.main_class(@application)
      end

      private

      def copy_application
        FileUtils.mkdir_p root
        @application.root.children.each { |child| FileUtils.cp_r child, root }
      end

      def copy_additional_libraries
        web_inf_lib = root + 'WEB-INF/lib'
        @droplet.additional_libraries.each { |additional_library| FileUtils.cp_r additional_library, web_inf_lib }
      end

      def create_dodeploy
        FileUtils.touch(webapps + 'ROOT.war.dodeploy')
      end

      def root
        webapps + 'ROOT.war'
      end

      def update_configuration
        standalone_config = @droplet.sandbox + 'standalone/configuration/standalone.xml'

        modified = standalone_config.read
                                    .gsub(%r{<location name="/" handler="welcome-content"/>},
                                          '<!-- <location name="/" handler="welcome-content"/> -->')

        standalone_config.open('w') { |f| f.write modified }
      end

      def webapps
        @droplet.sandbox + 'standalone/deployments'
      end

      def web_inf?
        (@application.root + 'WEB-INF').exist?
      end

    end

  end
end
