class MainCommand < BaseCommand
  def commands
    {   SC: :show_cards,
        CC: :create_card,
        DC: :destroy_card,
        PM: :put_money,
        WM: :withdraw_money,
        SM: :send_money,
        DA: :destroy_account,
        exit: :stop_loop }.freeze
  end
end
