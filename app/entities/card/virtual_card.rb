class VirtualCard < BaseCard
  def initialize(balance = 150)
    super
  end

  def withdraw_tax_percent
    5
  end

  def put_tax_fixed
    2
  end

  def sender_tax_fixed
    20
  end
end
