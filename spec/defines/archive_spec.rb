

require 'spec_helper'

describe 'borgbackup::archive' do
  let :default_params do
    { archive_name: 'title',
      pre_commands: [],
      post_commands: [],
      create_compression: 'lz4',
      create_filter: 'AME',
      create_options: ['verbose', 'list', 'stats', 'show-rc', 'exclude-caches'],
      create_excludes: [],
      create_includes: [],
      do_prune: true,
      prune_options: ['list', 'show-rc'],
      keep_daily: 7,
      keep_weekly: 4,
      keep_monthly: 6, }
  end

  shared_examples 'borgbackup::archive shared examples' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('borgbackup') }

    it {
      is_expected.to contain_concat__fragment('borgbackup::archive ' + params[:reponame] + ' create ' + params[:archive_name])
        .with_target('/etc/borgbackup/repo_' + params[:reponame] + '.sh')
        .with_order('20-' + title)
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        let(:title) { 'mytitle' }
        let :params do
          default_params.merge(
            archive_name: title,
            reponame: 'myrepo',
          )
        end

        it_behaves_like 'borgbackup::archive shared examples'

        it {
          is_expected.to contain_concat__fragment('borgbackup::archive ' + params[:reponame] + ' prune ' + params[:archive_name])
            .with_target('/etc/borgbackup/repo_' + params[:reponame] + '.sh')
            .with_order('70-' + title)
        }
      end

      context 'without prune' do
        let(:title) { 'mytitle' }
        let :params do
          default_params.merge(
            archive_name: title,
            reponame: 'anotherrepo',
            do_prune: false,
          )
        end

        it_behaves_like 'borgbackup::archive shared examples'

        it { is_expected.not_to contain_concat__fragment('borgbackup::archive ' + params[:reponame] + ' prune ' + params[:archive_name]) }
      end
    end
  end
end
