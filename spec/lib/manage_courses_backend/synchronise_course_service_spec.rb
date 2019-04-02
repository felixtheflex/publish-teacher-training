require 'rails_helper'

describe ManageCoursesBackend::SynchroniseCourseService do
  describe '#call' do
    let(:email) { 'email@example.com' }
    let(:token) do
      JWT.encode(
        email,
        Settings.authentication.secret,
        Settings.authentication.algorithm
      )
    end

    subject do
      described_class.call(
        provider_code: 'A0',
        course_code:   'C1D3',
        token:         token
      ).success?
    end

    before do
      stub_request(
        :post,
        "#{Settings.manage_backend.base_url}/api/v2/providers/A0/courses/" \
          "C1D3/sync_with_search_and_compare"
      ).to_return(response)
    end

    context 'when the action is successful' do
      let(:response) { { status: 200, body: '{ "result": true }' } }

      it { is_expected.to eq true }
    end
  end
end
