require 'spec_helper'
require 'kankri'

describe Kankri do
  describe '#authenticator_from_hash' do
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

      specify do
        expect(Kankri.authenticator_from_hash(hash)).to respond_to(
          :authenticate
        )
      end
    end
  end
end
