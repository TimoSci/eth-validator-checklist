require_relative '../src/generators'

RSpec.describe Template do

    name = "geth"

  template = Template.new(name)

  it "returns a path" do
    expect(template.path.empty?).to be false
  end 

  it "returns a path including name" do
    expect(template.path =~ /#{name}/).to be_truthy
  end 

  it "should fetch an erb object from file" do
    expect(ERB === template.get_erb).to be true
  end

  it "should parse a template" do
    expect(template.parse.empty?).to be false
  end

end