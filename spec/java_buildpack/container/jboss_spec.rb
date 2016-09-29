require 'spec_helper'
require 'component_helper'
require 'java_buildpack/container/jboss'

describe JavaBuildpack::Container::Jboss do
  include_context 'component_helper'

  let(:component) { StubJboss.new context }

  let(:configuration) { jboss_configuration }

  let(:jboss_configuration) { double('jboss-configuration') }

  it 'detects WEB-INF',
     app_fixture: 'container_jboss' do

    expect(component.detect).to include("jboss=#{version}")
  end

  it 'does not detect when WEB-INF is absent',
     app_fixture: 'container_main' do

    expect(component.detect).to be_nil
  end

  it 'extracts JBoss from a GZipped TAR',
     app_fixture:   'container_jboss',
     cache_fixture: 'stub-jboss.tar.gz' do

    component.compile

    expect(sandbox + 'bin/standalone.sh').to exist
  end

  it 'manipulates the standalone configuration',
     app_fixture:   'container_jboss',
     cache_fixture: 'stub-jboss.tar.gz' do

    component.compile

    configuration = sandbox + 'standalone/configuration/standalone.xml'
    expect(configuration).to exist

    contents = configuration.read
    expect(contents).to include('<socket-binding name="http" port="${http.port}"/>')
    expect(contents).to include('<virtual-server name="default-host" enable-welcome-root="false">')
  end

  it 'creates a "ROOT.war.dodeploy" in the deployments directory',
     app_fixture:   'container_jboss',
     cache_fixture: 'stub-jboss.tar.gz' do

    component.compile

    expect(sandbox + 'standalone/deployments/ROOT.war.dodeploy').to exist
  end

  it 'copies only the application files and directories to the ROOT webapp',
     app_fixture:   'container_jboss',
     cache_fixture: 'stub-jboss.tar.gz' do

    FileUtils.touch(app_dir + '.test-file')

    component.compile

    root_webapp = app_dir + '.java-buildpack/jboss/standalone/deployments/ROOT.war'

    web_inf = root_webapp + 'WEB-INF'
    expect(web_inf).to exist

    expect(root_webapp + '.test-file').not_to exist
  end

  it 'returns command',
     app_fixture: 'container_jboss' do

    expect(component.release).to eq("#{java_home.as_env_var} JAVA_OPTS=\"test-opt-2 test-opt-1 -Dhttp.port=$PORT\" " \
                                        '$PWD/.java-buildpack/jboss/bin/standalone.sh -b 0.0.0.0')
  end
end

class StubJboss < JavaBuildpack::Container::Jboss

  public :compile, :release, :supports?

end
