require 'rails_helper'

describe User do
  context 'from omniauth' do
    let(:provider) { 'facebook' }
    let(:uid) { '123456' }
    let(:email) { Faker::Internet.email }

    let(:request_data) { OpenStruct.new(provider: provider, uid: uid, info: OpenStruct.new(email: email)) }
    let(:request_data_without_email) { OpenStruct.new(provider: provider, uid: uid, info: OpenStruct.new) }

    it 'creates a user from provided data and populates provider fields' do
      user = User.from_omniauth(request_data)
      expect(user).to be_persisted
      expect(user.provider).to eq provider
      expect(user.uid).to eq uid
      expect(user.email).to eq email
    end

    it 'ignores user if email is not provided in oauth hash' do
      user = User.from_omniauth(request_data_without_email)
      expect(user).not_to be_persisted
    end

    it 'finds a user by provided data and authorizes them' do
      expect { User.from_omniauth(request_data) }.to change { User.count }.by 1
      expect do
        user = User.from_omniauth(request_data)
        expect(user).to be_a User
        expect(user).to be_persisted
      end.to change { User.count }.by 0
    end

    context 'issuing shares with market capital update' do
      let(:user) { create(:user) }
      let(:contract) { create(:contract) }
      let(:currency) { contract.currency }
      let(:market) { contract.market }

      it 'keeps track of market cap' do
        user.deposit_shares_with_market_cap(contract, 10)
        expect(user.shares(contract)).to eq 10
        expect(market.total_shares(currency)).to eq 10
        expect(market.contracts.where(currency: currency).count).to eq ContractTransaction.where(market: market).count
      end
    end
  end
end
