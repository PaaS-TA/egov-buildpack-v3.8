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

require 'spec_helper'
require 'component_helper'
require 'java_buildpack/container/jboss'

describe JavaBuildpack::Container::Jboss do
  include_context 'with component help'

  it 'detects WEB-INF',
     app_fixture: 'container_tomcat' do

    expect(component.detect).to include("jboss=#{version}")
  end

  it 'does not detect when WEB-INF is absent',
     app_fixture: 'container_main' do

    expect(component.detect).to be_nil
  end

  it 'extracts JBoss from a GZipped TAR',
     app_fixture: 'container_tomcat',
     cache_fixture: 'stub-jboss.tar.gz' do

    component.compile

    expect(sandbox + 'bin/standalone.sh').to exist
  end

  it 'manipulates the standalone configuration',
     app_fixture: 'container_tomcat',
     cache_fixture: 'stub-jboss.tar.gz' do

    component.compile

    configuration = sandbox + 'standalone/configuration/standalone.xml'
    expect(configuration).to exist

    contents = configuration.read
    expect(contents).to include('<!-- <location name="/" handler="welcome-content"/> -->')
  end

  it 'creates a "ROOT.war.dodeploy" in the deployments directory',
     app_fixture: 'container_tomcat',
     cache_fixture: 'stub-jboss.tar.gz' do

    component.compile

    expect(sandbox + 'standalone/deployments/ROOT.war.dodeploy').to exist
  end

  it 'copies only the application files and directories to the ROOT webapp',
     app_fixture: 'container_tomcat',
     cache_fixture: 'stub-jboss.tar.gz' do

    FileUtils.touch(app_dir + '.test-file')

    component.compile

    root_webapp = app_dir + '.java-buildpack/jboss/standalone/deployments/ROOT.war'

    web_inf = root_webapp + 'WEB-INF'
    expect(web_inf).to exist

    expect(root_webapp + '.test-file').not_to exist
  end

  it 'returns command',
     app_fixture: 'container_tomcat' do

    expect(component.release).to eq("test-var-2 test-var-1 JAVA_OPTS=$JAVA_OPTS #{java_home.as_env_var} exec " \
                                        '$PWD/.java-buildpack/jboss/bin/standalone.sh -b 0.0.0.0')
  end

end
