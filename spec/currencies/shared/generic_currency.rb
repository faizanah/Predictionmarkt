shared_examples "a generic currency" do
  context "implements basic methods" do
    it "responds to code" do
      expect(described_class.new.code.size).to eq 3
    end
  end
end
