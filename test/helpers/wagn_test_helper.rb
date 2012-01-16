require "#{Rails.root}/lib/util/card_builder.rb"
#require 'renderer'

module WagnTestHelper
      
  include CardBuilderMethods
 
  def setup_default_user
    User.cache.reset
    
    # FIXME: should login as joe_user by default-- see what havoc it creates...
    user_card = Card[Card::WagbotID]
    @user = User.current_user = User.find_by_login('wagbot')

    @user.update_attribute('crypted_password', '610bb7b564d468ad896e0fe4c3c5c919ea5cf16c')
    user_card.star_rule(:roles) << Card::AdminID
    
    # setup admin while we're at it
    #@admin_card = Card[User[:wagbot].card_id]

    #@admin_card.star_rule(:roles) << Card::AdminID
    #User.current_user = User.find_by_login('joe_user')
  end
 
  def get_renderer()
    Wagn::Renderer.new(Card.new(:name=>'dummy'))
  end
  
  def given_cards( *definitions )   
    User.as(:wagbot) do 
      Card.create_these *definitions
    end
  end
  # 
  # 
  # def card( name )
  #   Card.find_by_name(name)
  # end
  

  def render_test_card( card )
    Wagn::Renderer.new(card).process_content()
  end 
  
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
  

  def integration_login_as(user)
    User.cache.reset
    
    case user.to_s 
      when 'anon'; #do nothing
      when 'joe_user'; login='joe@user.com'; pass='joe_pass'
      when 'admin';    login='u3@user.com'; pass='u3_pass'
      else raise "Don't know email & password for #{user}"
    end
    unless user==:anon
      # FIXME- does setting controller here break anything else?
      #tmp_controller = @controller
      #@controller = AccountController.new
      
      post '/account/signin', :login=>login, :password=>pass
      assert_response :redirect
      
      #@controller = tmp_controller
    end
    if block_given?
      yield
      post "/account/signout",:controller=>'account'
    end
  end
  
  def post_invite(options = {})
    action = options[:action] || :invite
    post action, 
      :user => { :email => 'new@user.com' }.merge(options[:user]||{}),
      :card => { :name => "New User" }.merge(options[:card]||{}),
      :email => { :subject => "mailit",  :message => "baby"  }
  end 
  
#  def test_render(url)
#    get url
#    assert_response :success, "#{url} should render successfully"
#  end
  
#  def test_action(url, args={})
#    post( url, *args )
#    assert_response :success
#  end
  
  def assert_rjs_redirected_to(url)
    assert @response.body.match(/window\.location\.href = \"([^\"]+)\";/)
    assert_equal $~[1], url
  end
end

module Test
  module Unit
    module Assertions
      def assert_success(bypass_content_parsing = false)
        assert_response :success
        unless bypass_content_parsing  
          assert_nothing_raised(@response.content) { REXML::Document.new(@response.content) }  
        end
      end
    end
  end
end
