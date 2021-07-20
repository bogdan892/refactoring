RSpec.describe Console do
  let(:file_name) { 'spec/fixtures/account.yml' }
  let(:current_subject) { described_class.new }

  after do
    File.delete(file_name) if File.exist?(file_name)
  end

  describe '#console' do
    context 'when correct method calling' do
      after do
        current_subject.console
      end

      it 'create account if input is create' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'create' }
        expect(current_subject).to receive(:create)
      end

      it 'load account if input is load' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'load' }
        expect(current_subject).to receive(:load)
      end

      it 'leave app if input is exit or some another word' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'another' }
        expect(current_subject).to receive(:exit)
      end
    end

    context 'with correct outout' do
      it do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'test' }
        allow(current_subject).to receive(:exit)
        expect(current_subject).to receive(:puts).with(I18n.t('hello'))
        current_subject.console
      end
    end
  end

  describe '#create' do
    let(:success_inputs) { %w[Denis 72 success_login_input Denis1993] }

    context 'with success result' do
      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*success_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:accounts).and_return([])
      end

      it 'with correct out' do
        allow(File).to receive(:open)
        I18n.t('user').each_value { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        I18n.t('account_validation').values.map(&:values).each do |phrase|
          expect(current_subject).not_to receive(:puts).with(phrase)
        end
        current_subject.create
      end

      it 'write to file Account instance' do
        current_subject.instance_variable_set(:@db_path, file_name)
        current_subject.create
        expect(File.exist?(file_name)).to be true
        accounts = YAML.load_file(file_name)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a Account }
      end
    end

    context 'with errors' do
      before do
        all_inputs = current_inputs + success_inputs
        allow(File).to receive(:open)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:accounts).and_return([])
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:current_inputs) { [error_input, '72', 'Denis', 'Denis1993'] }

          it {
            expect do
              current_subject.create
            end.to output(/#{I18n.t('account_validation.name.first_letter')}/).to_stdout
          }
        end
      end

      context 'with login errors' do
        let(:current_inputs) { ['Denis', '72', error_input, 'Denis1993'] }

        context 'when present' do
          let(:error_input) { '' }

          it { expect { current_subject.create }.to output(/#{I18n.t('account_validation.login.present')}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * (AccountForm::MIN_LOGIN_LENGTH - 1) }

          it {
            expect do
              current_subject.create
            end.to output(/#{I18n.t('account_validation.login.longer',
                                    min: AccountForm::MIN_LOGIN_LENGTH)}/).to_stdout
          }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * (AccountForm::MAX_LOGIN_LENGTH + 1) }

          it {
            expect do
              current_subject.create
            end.to output(/#{I18n.t('account_validation.login.shorter',
                                    max: AccountForm::MAX_LOGIN_LENGTH)}/).to_stdout
          }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }

          before do
            allow(current_subject).to receive(:accounts) { [instance_double('Account', login: error_input)] }
          end

          it { expect { current_subject.create }.to output(/#{I18n.t('account_validation.login.exists')}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:current_inputs) { ['Denis', error_input, 'Denis', 'Denis1993'] }

        context 'with length minimum' do
          let(:error_input) { AccountForm::AGE.min - 1 }

          it { expect { current_subject.create }.to output(/#{I18n.t('account_validation.age.length')}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_input) { AccountForm::AGE.max + 1 }

          it { expect { current_subject.create }.to output(/#{I18n.t('account_validation.age.length')}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:current_inputs) { ['Denis', '72', 'Denis', error_input] }

        context 'when absent' do
          let(:error_input) { '' }

          it {
            expect do
              current_subject.create
            end.to output(/#{I18n.t('account_validation.password.present')}/).to_stdout
          }
        end

        context 'when longer' do
          let(:error_input) { 'E' * (AccountForm::MIN_PASSWORD_LENGTH - 1) }

          it {
            expect do
              current_subject.create
            end.to output(/#{I18n.t('account_validation.password.longer',
                                    min: AccountForm::MIN_PASSWORD_LENGTH)}/).to_stdout
          }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * (AccountForm::MAX_PASSWORD_LENGTH + 1) }

          it {
            expect do
              current_subject.create
            end.to output(/#{I18n.t('account_validation.password.shorter',
                                    max: AccountForm::MAX_PASSWORD_LENGTH)}/).to_stdout
          }
        end
      end
    end
  end

  describe '#load' do
    context 'without active accounts' do
      it do
        allow(current_subject).to receive(:accounts).and_return([])
        allow(current_subject).to receive(:create_first_account).and_return([])
        expect(current_subject).to receive(:create_first_account)
        current_subject.load
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }

      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(current_subject).to receive(:accounts) { [instance_double('Account', login: login, password: password)] }
      end

      context 'with correct outout' do
        let(:all_inputs) { [login, password] }

        it do
          expect(current_subject).to receive(:main_menu)
          [I18n.t('user.login'), I18n.t('user.password')].each do |phrase|
            expect(current_subject).to receive(:puts).with(phrase)
          end
          current_subject.load
        end
      end

      context 'when account exists' do
        let(:all_inputs) { [login, password] }

        it do
          expect(current_subject).to receive(:main_menu)
          expect { current_subject.load }.not_to output(/#{I18n.t('error.user_not_exists')}/).to_stdout
        end
      end

      context 'when account doesn\t exists' do
        let(:all_inputs) { ['test', 'test', login, password] }

        it do
          expect(current_subject).to receive(:main_menu)
          expect { current_subject.load }.to output(/#{I18n.t('error.user_not_exists')}/).to_stdout
        end
      end
    end
  end

  describe '#create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }

    it 'with correct outout' do
      allow(current_subject).to receive_message_chain(:gets, :chomp) {}
      allow(current_subject).to receive(:console)
      expect { current_subject.create_first_account }.to output("#{I18n.t('common.create_first_account')}\n").to_stdout
    end

    it 'calls create if user inputs is y' do
      allow(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
      expect(current_subject).to receive(:create)
      current_subject.create_first_account
    end

    it 'calls console if user inputs is not y' do
      allow(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect(current_subject).to receive(:console)
      current_subject.create_first_account
    end
  end

  describe '#main_menu' do
    let(:name) { 'John' }
    let(:commands) do
      {
        'SC' => :show_cards,
        'CC' => :create_card,
        'DC' => :destroy_card,
        'PM' => :put_money,
        'WM' => :withdraw_money,
        'SM' => :send_money,
        'DA' => :destroy_account,
        'exit' => :exit
      }
    end

    context 'with correct outout' do
      it do
        allow(current_subject).to receive(:show_cards)
        allow(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        expect { current_subject.main_menu }.to output(/#{I18n.t('main_operations', name: name)}/).to_stdout
      end
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }

      it 'calls specific methods on predefined commands' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        allow(current_subject).to receive(:exit)

        commands.each do |command, method_name|
          expect(current_subject).to receive(method_name)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          current_subject.main_menu
        end
      end

      it 'outputs incorrect message on undefined command' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        expect(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        expect { current_subject.main_menu }.to output(/#{I18n.t('error.wrong_command')}/).to_stdout
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }
    let(:accounts) do
      [instance_double('Account', login: 'test'), instance_double('Account', login: 'test1'),
       instance_double('Account', login: 'test2')]
    end

    before do
      allow(current_subject).to receive(:exit)
    end

    it 'with correct outout' do
      allow(current_subject).to receive_message_chain(:gets, :chomp) {}
      expect { current_subject.destroy_account }.to output("#{I18n.t('common.destroy_account')}\n").to_stdout
    end

    context 'when deleting' do
      it 'deletes account if user inputs is y' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
        allow(current_subject).to receive(:accounts) { accounts }
        expect(current_subject).to receive(:accounts)
        current_subject.instance_variable_set(:@db_path, file_name)
        current_subject.instance_variable_set(:@current_account, instance_double('Account', login: 'test'))

        current_subject.destroy_account

        expect(File.exist?(file_name)).to be true
        file_accounts = YAML.load_file(file_name)
        expect(file_accounts).to be_a Array
      end

      it 'doesnt delete account' do
        allow(current_subject).to receive(:input) { cancel_input }

        current_subject.destroy_account

        expect(File.exist?(file_name)).to be false
      end
    end
  end

  describe '#show_cards' do
    let(:cards) { [CapitalistCard.new, UsualCard.new, VirtualCard.new] }

    it 'display cards if there are any' do
      current_subject.instance_variable_set(:@current_account, instance_double('Account', cards: cards))
      cards.each { |card| expect(current_subject).to receive(:puts).with("- #{card.number}, #{card.type}") }
      current_subject.show_cards
    end

    it 'outputs error if there are no active cards' do
      current_subject.instance_variable_set(:@current_account, instance_double('Account', cards: []))
      expect(current_subject).to receive(:puts).with(I18n.t('error.no_active_cards'))
      current_subject.show_cards
    end
  end

  describe '#create_card' do
    let(:current_account) { Account.new(login: 'test', name: 'Alex') }

    context 'with correct outout' do
      it do
        expect(current_subject).to receive(:puts).with(I18n.t('create_card'))
        current_account.instance_variable_set(:@cards, [])
        current_subject.instance_variable_set(:@current_account, current_account)
        allow(current_subject).to receive(:accounts).and_return([])
        allow(File).to receive(:open)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('usual')
        expect(current_subject).to receive_message_chain(:gets, :chomp)

        current_subject.create_card
      end
    end

    context 'when correct card choose' do
      cards = {
        usual: UsualCard.new,
        capitalist: UsualCard.new,
        virtual: VirtualCard.new
      }
      before do
        current_subject.instance_variable_set(:@db_path, file_name)
        current_subject.instance_variable_set(:@current_account, current_account)
        allow(current_subject).to receive(:accounts) { [current_account] }
      end

      cards.each do |card_type, card|
        it "create card with #{card_type} type" do
          allow(current_subject).to receive_message_chain(:gets, :chomp) { card.type }

          current_subject.create_card

          expect(File.exist?(file_name)).to be true
          file_accounts = YAML.load_file(file_name)
          expect(file_accounts.first.cards.first.type).to eq card.type
          expect(file_accounts.first.cards.first.balance).to eq card.balance
          expect(file_accounts.first.cards.first.number.length).to be BaseCard::CARD_NUMBER_LENGTH
        end
      end
    end

    context 'when incorrect card choose' do
      it do
        current_account.instance_variable_set(:@cards, [])
        current_subject.instance_variable_set(:@current_account, current_account)
        allow(File).to receive(:open)
        allow(current_subject).to receive(:accounts).and_return([])
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect { current_subject.create_card }.to output(/#{I18n.t('error.wrong_card_type')}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    let(:current_account) { Account.new(login: 'test', name: 'Alex') }

    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: 'Alex', cards: []))
        expect { current_subject.destroy_card }.to output(/#{I18n.t('error.no_active_cards')}/).to_stdout
      end
    end

    context 'with cards' do
      # let(:card_one) { UsualCard.new }
      # let(:card_two) { CapitalistCard.new }
      let(:fake_cards) { [UsualCard.new, CapitalistCard.new] }

      context 'with correct output' do
        it do
          allow(current_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.destroy_card }.to output(/#{I18n.t('common.if_you_want_to_delete')}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.destroy_card }.to output(message).to_stdout
          end
          current_subject.destroy_card
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(current_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect(current_subject).to receive_message_chain(:gets, :chomp)
          current_subject.destroy_card
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(current_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_account)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{I18n.t('error.wrong_number')}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{I18n.t('error.wrong_number')}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:current_account) { Account.new(login: 'test', name: 'Alex') }

        before do
          current_subject.instance_variable_set(:@db_path, file_name)
          current_account.instance_variable_set(:@cards, fake_cards)
          allow(current_subject).to receive(:accounts) { [current_account] }
          current_subject.instance_variable_set(:@current_account, current_account)
        end

        it 'accept deleting' do
          commands = [1, 'y']
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card }.to change { current_account.cards.size }.by(-1)

          expect(File.exist?(file_name)).to be true
          file_accounts = YAML.load_file(file_name)
          expect(file_accounts.first.cards).not_to include(fake_cards.first)
        end

        it 'decline deleting' do
          commands = [1, 'asdf']
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card }.not_to change(current_account.cards, :size)
        end
      end
    end
  end

  describe '#put_money' do
    let(:current_account) { Account.new(login: 'test', name: 'Alex') }

    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', cards: []))
        expect { current_subject.put_money }.to output(/#{I18n.t('error.no_active_cards')}/).to_stdout
      end
    end

    context 'with cards' do
      let(:fake_cards) { [UsualCard.new, CapitalistCard.new] }

      context 'with correct outout' do
        it do
          allow(current_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.put_money }.to output(/#{I18n.t('common.choose_card')}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.put_money }.to output(message).to_stdout
          end
          current_subject.put_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(current_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect(current_subject).to receive_message_chain(:gets, :chomp)
          current_subject.put_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(current_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_account)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.put_money }.to output(/#{I18n.t('error.wrong_number')}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.put_money }.to output(/#{I18n.t('error.wrong_number')}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        card_one = CapitalistCard.new(50.00)
        card_two = CapitalistCard.new(100.00)
        let(:fake_cards) { [card_one, card_two] }

        chosen_card_number = 1
        incorrect_money_amount = -2
        correct_money_amount_lower_than_tax = 5
        correct_amount_greater = 50

        before do
          current_account.instance_variable_set(:@cards, fake_cards)
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to output(/#{I18n.t('common.input_amount')}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to output(/#{I18n.t('common.choose_card')}/).to_stdout
          end
        end

        context 'with tax greater than amount' do
          let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

          it do
            expect { current_subject.put_money }.to output(/#{I18n.t('error.tax_higher')}/).to_stdout
          end
        end

        context 'with tax lower than amount' do
          custom_cards =
            [UsualCard.new(50.0),
             CapitalistCard.new(50.0),
             VirtualCard.new(50.0)]

          let(:commands) { [chosen_card_number, correct_amount_greater] }

          it do
            custom_cards.each do |custom_card|
              commands = chosen_card_number, correct_amount_greater
              tax = custom_card.put_tax(correct_amount_greater)
              allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
              current_account.instance_variable_set(:@cards, [custom_card, card_one, card_two])
              expect { current_subject.put_money }.to output(
                /#{I18n.t('put_money', amount: correct_amount_greater, number: custom_card.number,
                                       balance: custom_card.balance + correct_amount_greater - tax, tax: tax)}/
              ).to_stdout
            end
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    let(:current_account) { Account.new(login: 'test', name: 'Alex') }

    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', cards: []))
        expect { current_subject.withdraw_money }.to output(/#{I18n.t('common.choose_card_withdrawing')}/).to_stdout
      end
    end

    context 'with cards' do
      context 'with correct outout' do
        let(:fake_cards) { [UsualCard.new, CapitalistCard.new] }

        it do
          allow(current_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.withdraw_money }.to output(/#{I18n.t('common.choose_card_withdrawing')}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.withdraw_money }.to output(message).to_stdout
          end
          current_subject.withdraw_money
        end
      end

      context 'when exit if first gets is exit' do
        let(:fake_cards) { [UsualCard.new, CapitalistCard.new] }

        it do
          allow(current_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('exit')
          expect(current_subject).to receive(:gets)
          current_subject.withdraw_money
        end
      end

      context 'with incorrect input of card number' do
        let(:fake_cards) { [UsualCard.new, CapitalistCard.new] }

        before do
          allow(current_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_account)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.withdraw_money }.to output(/#{I18n.t('error.wrong_number')}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.withdraw_money }.to output(/#{I18n.t('error.wrong_number')}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        before do
          current_account.instance_variable_set(:@cards, [UsualCard.new, CapitalistCard.new])
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          chosen_card_number = 1
          incorrect_money_amount = -2
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.withdraw_money }.to output(/#{I18n.t('common.withdraw_amount')}/).to_stdout
          end
        end
      end
    end
  end
end
