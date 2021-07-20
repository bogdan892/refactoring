class Account
  attr_reader :login, :password, :name, :age, :cards

  def initialize(params)
    @login = params[:login]
    @password = params[:password]
    @name = params[:name]
    @age = params[:age]
    @cards = []
  end
end
