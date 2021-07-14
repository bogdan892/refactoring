class WithdrawTransation < BaseTransaction
  def run
    @card.update_balance(new_balance) if valid?
    WithdrawTransationResult.new(card: @card, amount: @amount, errors: errors)
  end

  def validate
    if !@amount.positive?
      errors << I18n.t('error.invalid_amount')
    elsif !new_balance.positive?
      errors << I18n.t('error.tax_higher')
    end
  end

  def new_balance
    @card.balance - @amount - @card.withdraw_tax(@amount)
  end
end
