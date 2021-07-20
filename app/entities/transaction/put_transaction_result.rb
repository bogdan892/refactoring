class PutTransationResult < BaseTransactionResult
  def success_message
    I18n.t('put_money', amount: @amount, number: @card.number,
                        balance: @card.balance, tax: @card.put_tax(@amount))
  end
end
