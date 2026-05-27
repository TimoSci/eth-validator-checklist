require 'spec_helper'
require_relative '../src/cli'

RSpec.describe EthcheckCLI do
  it "registers checklist subcommand" do
    expect(described_class.subcommands).to include("checklist")
  end

  it "registers generate subcommand" do
    expect(described_class.subcommands).to include("generate")
  end

  it "registers install subcommand" do
    expect(described_class.subcommands).to include("install")
  end

  it "registers uninstall subcommand" do
    expect(described_class.subcommands).to include("uninstall")
  end

  it "registers update subcommand" do
    expect(described_class.subcommands).to include("update")
  end
end

RSpec.describe ChecklistCLI do
  %w[users system_checks timekeeping firewall clients all].each do |cmd|
    it "has #{cmd} command" do
      expect(described_class.commands.keys).to include(cmd)
    end
  end
end
