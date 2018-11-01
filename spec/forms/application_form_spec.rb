require 'rails_helper'

RSpec.describe ApplicationForm do
  it 'saves the form' do
    form = ApplicationForm.new
    expect(form.save).to eq true
    expect(form.errors.size).to eq 0
  end
end
