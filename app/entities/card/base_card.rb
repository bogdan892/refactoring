class BaseCard
  CARD_TYPES = {
    'UsualCard' => :usual,
    'CapitalistCard' => :capitalist,
    'VirtualCard' => :virtual
  }.freeze
  CARD_NUMBER_LENGTH = 16

  attr_reader :balance

  def self.create(type, *args)
    case type
    when :usual then UsualCard.new(*args)
    when :capitalist then CapitalistCard.new(*args)
    when :virtual then VirtualCard.new(*args)
    end
  end

  def initialize(balance = 0)
    @balance = balance
    @number = number
  end

  def type
    CARD_TYPES[self.class.to_s]
  end

  def number
    @number ||= Array.new(CARD_NUMBER_LENGTH) { rand(9) }.join
  end

  def withdraw_money(amount)
    WithdrawTransation.new(self, amount).run
  end

  def put_money(amount)
    PutTransaction.new(self, amount).run
  end

  def send_money(amount, recipient_card)
    SendTransaction.new(self, recipient_card, amount).run
  end

  def withdraw_tax_percent
    raise NoImplementedError
  end

  def put_tax_percent
    0
  end

  def put_tax_fixed
    0
  end

  def sender_tax_percent
    0
  end

  def sender_tax_fixed
    0
  end

  def withdraw_tax(amount)
    amount * withdraw_tax_percent / 100.0
  end

  def put_tax(amount)
    amount * put_tax_percent / 100.0 + put_tax_fixed
  end

  def sender_tax(amount)
    amount * sender_tax_percent / 100.0 + sender_tax_fixed
  end

  def update_balance(balance)
    @balance = balance
  end
end
