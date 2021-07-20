class CardNumber < ValidableEntity
  def initialize(manager, card_number)
    super()
    @action = manager
    @card_number = card_number
  end

  def card
    @action.find_card_by_number(@card_number)
  end

  def validate
    if @card_number.length != 16
      errors << I18n.t('error.no_card_with_number', number: @card_number)
    elsif !@action.card_with_number_exists?(@card_number)
      errors << I18n.t('error.wrong_card_number')
    end
  end
end
