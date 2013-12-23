
describe Kankri::PasswordCheck do
  let(:passwords) { { test: 'hunter2' } }
  subject { ->(u, p) { Kankri::PasswordCheck.new(u, p, passwords) } }

  describe '#ok?' do
    context 'with a valid username and password' do
      specify { expect(subject.call(:test, 'hunter2').ok?).to be_true }
    end
    context 'with a valid username and invalid password' do
      specify { expect(subject.call(:test, 'nope').ok?).to be_false }
    end
    context 'with an invalid username and password' do
      specify { expect(subject.call(:toast, 'nope').ok?).to be_false }
    end
    context 'with a valid username and blank password' do
      specify { expect(subject.call(:test, '').ok?).to be_false }
    end
    context 'with a blank username and password' do
      specify { expect(subject.call(:'', '').ok?).to be_false }
    end
    context 'with a valid username and nil password' do
      specify { expect(subject.call(:test, nil).ok?).to be_false }
    end
    context 'with a nil username and password' do
      specify { expect(subject.call(nil, nil).ok?).to be_false }
    end
  end
end
