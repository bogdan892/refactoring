class CardType < ValidableEntity
  attr_reader :type

  def initialize(type)
    super()
    @type = type.to_sym
  end

  def validate
    errors << I18n.t('error.wrong_card_type') unless BaseCard::CARD_TYPES.invert.key?(type)
  end
end
