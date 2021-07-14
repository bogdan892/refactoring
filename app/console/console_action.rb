module ConsoleAction
  def create_card
    card_type_input { |card_type| action.create_card(current_account, card_type) }
  end

  def destroy_card
    destroy_card_input(current_account) do |card|
      action.destroy_card(current_account, card) if confirm?('common.destroy_card', number: card.number)
    end
  end

  def show_cards
    any_cards?(current_account) { current_account.cards.each { |card| puts "- #{card.number}, #{card.type}" } }
  end

  def withdraw_money
    withdraw_card_input(current_account) do |card|
      puts action.withdraw_money(current_account, card, withdraw_amount_input)
    end
  end

  def put_money
    put_card_input(current_account) do |card|
      puts action.put_money(current_account, card, put_amount_input)
    end
  end

  def send_money
    send_card_input(current_account) do |sender_card|
      recipient_card_number_input do |recipient_card|
        puts action.send_money(current_account, sender_card, recipient_card, send_amount_input)
      end
    end
  end

  def load
    return create_first_account if action.no_accounts?

    loop { break if load_account }
    main_menu
  end

  def create
    fill_account_form(action) { |form| change_current_account(form.create_account) }
    main_menu
  end

  def destroy_account
    confirm?('common.destroy_account') && action.destroy_account(current_account) && exit
  end

  def create_first_account
    confirm?('common.create_first_account') ? create : console
  end

  def load_account
    account = action.find_by_login_password(input('user.login'), input('user.password'))
    output('error.user_not_exists') unless account
    change_current_account(account)
  end
end
