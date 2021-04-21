#
# Classes for interacting with web api (eg github)
#

module GithubApi

  #TODO use ruby internal jsonrpc-client

  def get_latest_version(project)
    return nil unless project
    command = %q{curl --silent "https://api.github.com/repos/}+project+%q{/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'}
    result = %x|#{command}|
    result.chomp
  end


end
