require 'feature_helper'

describe 'Basic pages, accessible to anyone' do
  %w[security terms fees].each do |a|
    it "browses /#{a} page" do
      visit url_for(controller: 'pages', action: a, only_path: true)
      expect(page).to have_selector('.page-content', visible: false)
      expect(page).not_to have_selector('.alert')
      snap('pages', a)
    end
  end
end
