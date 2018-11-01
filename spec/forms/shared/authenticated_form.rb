shared_examples "an authenticated form" do
  it 'runs validation callbacks, requires user' do
    form = described_class.new
    expect(form.save).to eq false
    expect(form.errors.size).to be >= 1
    expect(form.errors.keys.include?(:user)).to eq true
  end
end
