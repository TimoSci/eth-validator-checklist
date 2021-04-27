require_relative '../src/checklist'

RSpec.describe Firewall do

  firewall = Firewall.new

  it "correctly returns active and inactive status" do
    `sudo ufw disable`
    expect(firewall.active?).to be false
    `sudo ufw enable`
    expect(firewall.active?).to be true
  end

end
