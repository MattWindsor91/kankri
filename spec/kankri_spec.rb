require 'spec_helper'
require 'kankri'

describe Kankri do
  describe '#authenticator_from_hash' do
    let(:auth) { ->{ Kankri.authenticator_from_hash(hash) } }
    context 'when given a valid hash of users' do
      let(:hash) do
        {
          username: {
            password: 'foo',
            privileges: {
              key_one: :all,
              key_two: [:priv_one, :priv_two, :priv_three],
              key_three: []
            }
          }
        }
      end

      specify { expect(auth.call).to respond_to(:authenticate) }
    end
    context 'when given a hash with a user with no password' do
      let(:hash) do
        {
          test: {
            privileges: {
              channel_set: ['get'],
              channel: 'all'
            }
          }
        }
      end

      specify { expect { auth.call }.to raise_error }
    end
    context 'when given a hash with a user with no privileges' do
      let(:hash) do
        {
          test: {
            password: 'hunter2'
          }
        }
      end

      specify { expect { auth.call }.to raise_error }
    end

    context 'when given something that is not a hash' do
      let(:hash) { 'not a hash' }

      specify { expect { auth.call }.to raise_error }
    end
  end
end
