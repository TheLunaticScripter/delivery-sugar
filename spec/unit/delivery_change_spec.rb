require 'spec_helper'

describe DeliverySugar::Change do
  let(:node) do
    {
      'delivery' => {
        'workspace' => {
          'repo' => 'workspace_repo'
        },
        'change' => {
          'stage' => stage,
          'enterprise' => 'ent',
          'organization' => 'org',
          'project' => 'proj',
          'pipeline' => 'pipe',
          'patchset_branch' => 'patchset_branch'
        }
      }
    }
  end

  subject { DeliverySugar::Change.new node }

  describe '#initialize' do
    let(:stage) { 'stage_name' }

    it 'sets attributes correctly' do
      expect(subject.enterprise).to eql('ent')
      expect(subject.organization).to eql('org')
      expect(subject.project).to eql('proj')
      expect(subject.pipeline).to eql('pipe')
      expect(subject.stage).to eql('stage_name')
      expect(subject.patchset_branch).to eql('patchset_branch')
      expect(subject.workspace_repo).to eql('workspace_repo')
    end
  end

  describe '#acceptance_environment' do
    let(:stage) { 'stage_name' }

    it 'returns the fully qualified environment name' do
      expect(subject.acceptance_environment).to eql('acceptance-ent-org-proj-pipe')
    end
  end

  describe '#environment_for_current_stage' do
    context 'when current stage is acceptance' do
      let(:stage) { 'acceptance' }

      it 'returns acceptance environment' do
        expect(subject).to receive(:acceptance_environment)
          .and_return(:some_result)
        expect(subject.environment_for_current_stage).to eql(:some_result)
      end
    end

    context 'when the current stage is not acceptance' do
      let(:stage) { 'not_acceptance' }

      it 'returns name of stage' do
        expect(subject.environment_for_current_stage).to eql('not_acceptance')
      end
    end
  end

  describe '#changed_files' do
    let(:stage) { 'unused' }
    let(:client) { double("DeliverySugar::SCM") }
    let(:list_of_files) { [] }
    let(:branch1) { 'pipe' }
    let(:branch2) { 'patchset_branch' }
    let(:workspace) { 'workspace_repo' }

    it 'calls the git client' do
      expect(subject).to receive(:scm_client).and_return(client)
      expect(client).to receive(:changed_files).with(workspace, branch1, branch2).and_return(list_of_files)

      expect(subject.changed_files).to eql(list_of_files)
    end
  end
end
