module ConsoleHelper
  EXIT = 'exit'.freeze
  YES = 'y'.freeze

  def exit?(command)
    command == EXIT
  end

  def confirm?(*args, **value)
    input(*args, **value) == YES
  end

  def stop_loop
    raise StopIteration
  end

  def input(*args, **value)
    output(*args, **value) unless args.empty?
    gets.chomp
  end

  def output(*args, **value)
    puts I18n.t(*args, **value)
  end
end
