require 'rho/rhocontroller'
require 'helpers/browser_helper'

class SessionsController < Rho::RhoController
  include BrowserHelper

  # GET /Sessions
  def index
    @msg = @params['msg']
      puts "#########################  #{@params}"
    #render :back => '/app'
      render :action=> :index
  end

  def do_login
    @@get_result = ""

    login = @params['login']
    password = @params['password']
    puts "######################L  #{login}"
    puts "#######################P    #{password}"
    #body = '{"email" : "'+ login +'","password" :"'+ password +'"  } }'

    @result =  Rho::AsyncHttp.post(:url => Rho::RhoConfig.RESTFUL_URL + "tokens.json?email=#{login}&password=#{password}",
                                   :callback => (url_for :action => :httpget_callback),
                                   :callback_param => "",
                                   :http_command => "POST", :headers => {"Content-Type" => "application/json"})

    @response['headers']['Wait-Page'] = 'true'
    render :action => :wait

  end

  def wait
    render
  end

  def get_res
    @@get_result
  end

  def get_error
    @@error_params
  end

  def httpget_callback
    puts "-----> httpget_callback: #{@params}"
    puts "########## REspone : #{@params['body']}"
    puts "########## Message : #{@params['body'][0]['message']}"
    
    if @params['status'] != 'ok'
      @@error_params = @params
     # WebView.navigate ( url_for :action => :show_error )
      @msg = @params['body']['message'] if @params['body']
      WebView.navigate ( url_for :action => :index, :query => {:msg =>@msg} )
    else
      @@get_result = @params['body']
      WebView.navigate ( url_for :controller=>:requisition,:action => :index )
    end
  end



  def show_error
    render :action => :error, :back => '/app'
  end


  def cancel_httpcall
    Rho::AsyncHttp.cancel( url_for( :action => :httpget_callback) )
    @@get_result = 'Request was cancelled.'
    render :action => :index, :back => '/app'
  end








# GET /Sessions/{1}
  def show
    @sessions = Sessions.find(@params['id'])
    if @sessions
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

# GET /Sessions/new
  def new
    @sessions = Sessions.new
    render :action => :new, :back => url_for(:action => :index)
  end

# GET /Sessions/{1}/edit
  def edit
    @sessions = Sessions.find(@params['id'])
    if @sessions
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

# POST /Sessions/create
  def create
    @sessions = Sessions.create(@params['sessions'])
    redirect :action => :index
  end

# POST /Sessions/{1}/update
  def update
    @sessions = Sessions.find(@params['id'])
    @sessions.update_attributes(@params['sessions']) if @sessions
    redirect :action => :index
  end

# POST /Sessions/{1}/delete
  def delete
    @sessions = Sessions.find(@params['id'])
    @sessions.destroy if @sessions
    redirect :action => :index
  end
end
