require 'rails_helper'

describe Money do
  context 'BTC subunits' do
    let(:one_btc) { Money.from_amount(1, 'BTC') }
    let(:one_mbtc) { Money.from_amount(1, 'MBTC') }

    it 'converts BTC to MBTC' do
      expect(one_btc.exchange_to('MBTC').amount).to eq 1000
      expect(one_btc.exchange_to('UBTC').amount).to eq 1_000_000
    end

    it 'converts MBTC to BTC' do
      expect(one_mbtc.exchange_to('BTC').amount).to eq 0.001
      expect(one_mbtc.exchange_to('UBTC').amount).to eq 1000
    end
  end

  context 'ETH subunits' do
    let(:one_eth)  { Money.from_amount(1, 'ETH') }
    let(:one_gwei) { Money.from_amount(1, 'GWEI') }
    let(:one_wei)  { Money.new(1, 'GWEI') }

    it 'converts ETH to GWEI' do
      expect(one_eth.exchange_to('GWEI').amount).to eq 1_000_000_000
      expect(one_gwei.exchange_to('ETH').amount).to eq 0.000_000_001
    end

    it 'converts wei to ETH' do
      expect(one_wei.exchange_to('ETH').amount).to eq 0.000000000000000001
      expect(one_wei * 1_000_000_000).to eq one_gwei
      expect(one_gwei * 1_000_000_000).to eq one_eth
    end
  end
end
