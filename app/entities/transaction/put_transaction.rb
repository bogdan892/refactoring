class PutTransaction < BaseTransaction
  def run
    @card.update_balance(new_balance) if valid?
    PutTransationResult.new(card: @card, amount: @amount, errors: errors)
  end

  def validate
    if !@amount.positive?
      errors << I18n.t('error.invalid_amount')
    elsif tax >= @amount
      errors << I18n.t('error.tax_higher')
    end
  end

  def new_balance
    @card.balance + @amount - tax
  end

  def tax
    @card.put_tax(@amount)
  end
end
