require 'java_buildpack/util'
require 'java_buildpack/util/configuration_utils'
require 'java_buildpack/util/configuration_utils_for_was'
require 'logging_helper'
require 'pathname'
require 'spec_helper'
require 'yaml'

describe JavaBuildpack::Util::ConfigurationUtilsForWAS do
  include_context 'logging_helper'

  context do
    before do
      allow(YAML).to receive(:load_file).and_return('containers' => %w(1 JavaBuildpack::Container::Jboss),
                                                    'jres' => %w(1 2),
                                                    'frameworks' =>
                                                        %w(1 JavaBuildpack::Framework::SpringAutoReconfiguration))

    end

    context 'when provided object is not a Array' do
      let(:file) { Pathname.new 'test.yml' }
      let(:user_provided) { 'container Tomcat' }

      it 'raise Type error' do
        expect { described_class.load_components_configuration(file, user_provided, true) }
            .to raise_error { |error| expect(error).to be_a(RuntimeError) }
      end
    end

    context 'when provided key is not a valid' do
      let(:file) { Pathname.new 'test.yml' }
      let(:user_provided) { '[container: Tomcat]' }

      it 'raise Runtime error' do
        expect { described_class.load_components_configuration(file, user_provided, true) }
            .to raise_error { |error| expect(error).to be_a(RuntimeError) }
      end
    end
  end

end
