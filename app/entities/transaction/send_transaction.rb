class SendTransaction < BaseTransaction
  def initialize(sender_card, recipient_card, amount)
    super()
    @sender_card = sender_card
    @recipient_card = recipient_card
    @amount = amount
  end

  def run
    if valid?
      @sender_card.update_balance(sender_new_balance)
      @recipient_card.update_balance(recipient_new_balance)
    end
    SendTransactionResult.new(card: @sender_card, recipient_card: @recipient_card, amount: @amount, errors: errors)
  end

  def validate
    validate_amount && validate_sender_balance && validate_recipient_tax
  end

  def validate_amount
    errors << I18n.t('error.invalid_amount') unless @amount.positive?
    errors.empty?
  end

  def validate_sender_balance
    errors << I18n.t('error.not_enough_money') if sender_new_balance.negative?
    errors.empty?
  end

  def validate_recipient_tax
    errors << I18n.t('error.not_enough_money_sender_card') if recipient_tax >= @amount
    errors.empty?
  end

  def sender_tax
    @sender_card.sender_tax(@amount)
  end

  def recipient_tax
    @recipient_card.put_tax(@amount)
  end

  def sender_new_balance
    @sender_card.balance - @amount - sender_tax
  end

  def recipient_new_balance
    @recipient_card.balance + @amount - recipient_tax
  end
end
