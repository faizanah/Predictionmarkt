shared_examples "a chainable transaction" do
  let(:initial_total) { transaction.total }

  it "does not allow to be destroyed" do
    transaction.destroy
    expect(described_class.exists?(transaction.id)).to eq true
  end

  it "does not allow to be updated" do
    transaction.update_attributes(total: 10)
    transaction.reload
    expect(transaction.total).to eq initial_total
  end

  it "chains to the previous transaction" do
    new_tx = create_next_tx(transaction)
    expect(new_tx.prev_id).to eq transaction.id
    expect(new_tx.total).to eq 10 + initial_total
  end

  it "returns the last transactions" do
    tx2 = create_next_tx(create_next_tx(transaction))
    scope = {}
    transaction.trx_scope_options.each do |name, value|
      scope[name] = value
      last_tx = transaction.class.last_transactions(scope)
      expect(last_tx).to eq [tx2]
    end
  end

  def create_next_tx(tx, total_change = 10)
    opts = { reason: tx.reason, total_change: total_change }
    opts[:cause] = tx.cause if tx.respond_to?(:cause)
    create(transaction.class.to_s.underscore.to_sym,
           transaction.trx_scope_options.merge(opts))
  end
end
