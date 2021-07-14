class WithdrawTransationResult < BaseTransactionResult
  def success_message
    I18n.t('withdraw_money', amount: @amount, number: @card.number,
                             balance: @card.balance, tax: @card.withdraw_tax(@amount))
  end
end
