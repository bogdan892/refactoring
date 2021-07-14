class BaseTransaction < ValidableEntity
  def initialize(card, amount)
    super()
    @card = card
    @amount = amount
  end
end
