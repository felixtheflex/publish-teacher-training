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
      )
    end

    context 'when the server responds' do
      before do
        stub_request(
          :post,
          "#{Settings.manage_backend.base_url}/api/v2/providers/A0/courses/" \
            "C1D3/sync_with_search_and_compare"
        ).to_return(response)
      end

      context 'when the action is successful' do
        let(:response) { { status: 200, body: '{ "result": true }' } }

        it 'it has no errors' do
          expect(subject.success?).to be true
          expect(subject.errors).to be_empty
        end
      end

      context 'when the action is unsuccessful' do
        let(:response) { { status: 200, body: '{ "result": false }' } }

        it 'sets an error message' do
          expect(subject.success?).to be false
          expect(subject.errors).not_to be_empty
        end
      end
    end

    context 'when there is a network error' do
      before do
        stub_request(
          :post,
          "#{Settings.manage_backend.base_url}/api/v2/providers/A0/courses/" \
            "C1D3/sync_with_search_and_compare"
        ).to_raise(Faraday::Error::ConnectionFailed)
      end

      it 'sets an error message' do
        expect(subject.success?).to be false
        expect(subject.errors).not_to be_empty
      end
    end
  end
end
