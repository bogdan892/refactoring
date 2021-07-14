class Console
  include ConsoleHelper
  include AccountInputs
  include CardInputs
  include ConsoleAction

  DB_PATH = File.expand_path('accounts.yml', __dir__)

  attr_reader :current_account

  def initialize
    @db_path = DB_PATH
  end

  def console
    output('hello')
    command = ConsoleCommand.new(input)
    command.valid? ? command.run(self) : exit
  end

  def main_menu
    loop do
      output('main_operations', name: @current_account.name)
      command = MainCommand.new(input)
      command.valid? ? command.run(self) : puts(command.errors)
    end
    exit
  end

  private

  def change_current_account(current_account)
    @current_account = current_account
  end

  def accounts
    store.load
  end

  def action
    @action = AccountAction.new(store, accounts)
  end

  def store
    @store = YamlStore.new(@db_path)
  end
end
