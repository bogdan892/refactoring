class ConsoleCommand < BaseCommand
  def commands
    {   create: :create,
        load: :load,
        exit: :exit }.freeze
  end
end
