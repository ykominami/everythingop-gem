require 'spec_helper'

RSpec.describe Everythingop do
  let(:data_dir) { test_file_base_pn.join('data') }
  #  let(:group_file) { data_dir.join("20221004.yml") }
  #  let(:group_file) { data_dir.join("20221004_2.yml") }
  let(:group_file) { data_dir.join('20221004_3.yml') }
  let(:in_file) { data_dir.join('20220727-git.efu') }
  let(:verbose) { false }
  let(:args_s) { %w[--cmd=s --verbose] }
  let(:args_f) { %W[--cmd=f --verbose --infile=#{in_file} --group=#{group_file}] }
  # let(:cli_f) { Everythingop::Cli.new(args_f) }
  # let(:hash) { cli.setup }
  # let(:hash) { test_setup }
  let(:opts) { {} }

  it 'has a version number', cmd: :v do
    expect(Everythingop::VERSION).not_to be_nil
  end

  context 'when Everythingop use group' do
    it 'cmd f', cmd: :f do
      cli = Everythingop::Cli.new(args_f)
      cli.setup_for_startup
      # cli.startup
      # eto = cli.cli_eto
      # カレントのリポジトリの一覧
      expect(cli.cli_f).not_to be_nil
    end
  end
end
