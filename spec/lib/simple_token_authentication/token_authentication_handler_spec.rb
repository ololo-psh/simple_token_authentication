require 'spec_helper'

describe 'Any class which includes SimpleTokenAuthentication::TokenAuthenticationHandler' do

  let(:described_class) do
    define_dummy_class_which_includes SimpleTokenAuthentication::TokenAuthenticationHandler
  end

  after(:each) do
    # ensure_examples_independence
    SimpleTokenAuthentication.send(:remove_const, :SomeClass)
  end

  it_behaves_like 'a token authentication handler'

  let(:subject) { described_class }

  describe '.handle_token_authentication_for' do

    before(:each) do
      double_user_model
    end

    it 'ensures token authentication is handled for a given (token authenticatable) model', public: true do
      entities_manager = double()
      allow(entities_manager).to receive(:find_or_create_entity).and_return('entity')

      # skip steps which are not relevant in this example
      SimpleTokenAuthentication.stub(:fallback).and_return('default')
      subject.stub(:entities_manager).and_return(entities_manager)
      subject.stub(:set_token_authentication_hooks)
      subject.stub(:define_token_authentication_helpers_for)

      expect(subject).to receive(:set_token_authentication_hooks).with('entity', {option: 'value', fallback: 'default'})
      subject.handle_token_authentication_for(User, {option: 'value'})
    end
  end

  describe '.entities_manager' do

    before(:each) do
      # The private tag is here to keep the following examples out of
      # the public documentation.
      subject.send :public_class_method, :entities_manager

      SimpleTokenAuthentication::EntitiesManager.stub(:new)
        .and_return('a EntitiesManager instance')
    end

    context 'when called for the first time' do

      it 'creates a new EntitiesManager instance', private: true do
        expect(SimpleTokenAuthentication::EntitiesManager).to receive(:new)
        expect(subject.entities_manager).to eq 'a EntitiesManager instance'
      end
    end

    context 'when a EntitiesManager instance was already created' do

      before(:each) do
        subject.entities_manager
        # let's make any new EntitiesManager distinct from the first
        SimpleTokenAuthentication::EntitiesManager.stub(:new)
        .and_return('another EntitiesManager instance')
      end

      it 'returns that instance', private: true do
        expect(subject.entities_manager).to eq 'a EntitiesManager instance'
      end

      it 'does not create a new EntitiesManager instance', private: true do
        expect(SimpleTokenAuthentication::EntitiesManager).not_to receive(:new)
        expect(subject.entities_manager).not_to eq 'another EntitiesManager instance'
      end
    end
  end

  describe '.fallback_authentication_handler' do

    before(:each) do
      # The private tag is here to keep the following examples out of
      # the public documentation.
      subject.send :public_class_method, :fallback_authentication_handler

      SimpleTokenAuthentication::FallbackAuthenticationHandler.stub(:new)
        .and_return('a FallbackAuthenticationHandler instance')
    end

    context 'when called for the first time' do

      it 'creates a new FallbackAuthenticationHandler instance', private: true do
        expect(SimpleTokenAuthentication::FallbackAuthenticationHandler).to receive(:new)
        expect(subject.fallback_authentication_handler({})).to eq 'a FallbackAuthenticationHandler instance'
      end
    end

    context 'when a FallbackAuthenticationHandler instance was already created' do

      before(:each) do
        subject.fallback_authentication_handler({})
        # let's make any new FallbackAuthenticationHandler distinct from the first
        SimpleTokenAuthentication::FallbackAuthenticationHandler.stub(:new)
        .and_return('another FallbackAuthenticationHandler instance')
      end

      it 'returns that instance', private: true do
        expect(subject.fallback_authentication_handler({})).to eq 'a FallbackAuthenticationHandler instance'
      end

      it 'does not create a new FallbackAuthenticationHandler instance', private: true do
        expect(SimpleTokenAuthentication::FallbackAuthenticationHandler).not_to receive(:new)
        expect(subject.fallback_authentication_handler({})).not_to eq 'another FallbackAuthenticationHandler instance'
      end
    end
  end

  describe 'and which supports the :before_filter hook' do

    before(:each) do
      subject.stub(:before_filter)
    end

    # User

    context 'and which handles token authentication for User' do

      before(:each) do
        double_user_model
      end

      it 'ensures its instances require user to authenticate from token or any Devise strategy before any action', public: true do
        expect(subject).to receive(:before_filter).with(:authenticate_user_from_token!, {})
        subject.handle_token_authentication_for User
      end

      context 'and disables the fallback to Devise authentication' do

        let(:options) do
          { fallback_to_devise: false }
        end

        it 'ensures its instances require user to authenticate from token before any action', public: true do
          expect(subject).to receive(:before_filter).with(:authenticate_user_from_token, {})
          subject.handle_token_authentication_for User, options
        end
      end

      describe 'instance' do

        before(:each) do
          double_user_model

          subject.class_eval do
            handle_token_authentication_for User
          end
        end

        it 'responds to :authenticate_user_from_token', protected: true do
          expect(subject.new).to respond_to :authenticate_user_from_token
        end

        it 'responds to :authenticate_user_from_token!', protected: true do
          expect(subject.new).to respond_to :authenticate_user_from_token!
        end

        it 'does not respond to :authenticate_super_admin_from_token', protected: true do
          expect(subject.new).not_to respond_to :authenticate_super_admin_from_token
        end

        it 'does not respond to :authenticate_super_admin_from_token!', protected: true do
          expect(subject.new).not_to respond_to :authenticate_super_admin_from_token!
        end
      end
    end

    # SuperAdmin

    context 'and which handles token authentication for SuperAdmin' do

      before(:each) do
        double_super_admin_model
      end

      it 'ensures its instances require super_admin to authenticate from token or any Devise strategy before any action', public: true do
        expect(subject).to receive(:before_filter).with(:authenticate_super_admin_from_token!, {})
        subject.handle_token_authentication_for SuperAdmin
      end

      context 'and disables the fallback to Devise authentication' do

        let(:options) do
          { fallback_to_devise: false }
        end

        it 'ensures its instances require super_admin to authenticate from token before any action', public: true do
          expect(subject).to receive(:before_filter).with(:authenticate_super_admin_from_token, {})
          subject.handle_token_authentication_for SuperAdmin, options
        end
      end

      describe 'instance' do

        before(:each) do
          double_super_admin_model

          subject.class_eval do
            handle_token_authentication_for SuperAdmin
          end
        end

        it 'responds to :authenticate_super_admin_from_token', protected: true do
          expect(subject.new).to respond_to :authenticate_super_admin_from_token
        end

        it 'responds to :authenticate_super_admin_from_token!', protected: true do
          expect(subject.new).to respond_to :authenticate_super_admin_from_token!
        end

        it 'does not respond to :authenticate_user_from_token', protected: true do
          expect(subject.new).not_to respond_to :authenticate_user_from_token
        end

        it 'does not respond to :authenticate_user_from_token!', protected: true do
          expect(subject.new).not_to respond_to :authenticate_user_from_token!
        end
      end
    end
  end
end
