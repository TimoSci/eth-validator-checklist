require_relative '../src/installers'
require_relative '../src/checklist'
require 'pry'




RSpec.describe PrysmInstaller do

  checklist = Eth2Checklist.new
  installer = PrysmInstaller.new(checklist)

  it "creates and deletes the prysm data diractory" do

    installer.create_data_directory
    expect(checklist.clients.prysmbeacon.installation_directory).to be_truthy
    installer.remove_data_directory
    expect(checklist.clients.prysmbeacon.installation_directory).to be_falsy

  end

  it "downloads and copies, and deletes the prysm executable" do

    installer.remove_executable
    expect(checklist.clients.prysmbeacon.get_executable_path).to be_falsy
    installer.copy_executable
    expect(checklist.clients.prysmbeacon.get_executable_path).to be_truthy
    installer.remove_executable
    expect(checklist.clients.prysmbeacon.get_executable_path).to be_falsy

  end

end