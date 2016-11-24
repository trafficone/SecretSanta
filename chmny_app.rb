require 'rubygems'
require 'sinatra'
require 'haml'
require 'sequel'
#requires sqlite3 gem to be installed

#TODO: User ID needs to be passed with some sort of session ID in cookies

configure do
	Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://chmny.db')
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'models'

set :environment, 'development'
set :public_dir, 'public'
set :views, 'views'

helpers do
    def user_is_authorized?
        #FIXME: this isn't auth
        return request.cookies['userid'] == request.params['userid'] 
    end
    def auth
        stop [ 401, 'Not authorized'] unless user_is_authorized?()
    end
end
#get landing 
get '/' do
    #FIXME: this just fails
    haml("= render_login_logout", :layout => :layout)
end

#get auth users
get '/auth' do
    #TODO: create login template
    return "Login goes here"
end

#set user auth
post '/auth' do
    #FIXME:  need auth keys and authentication processes
    set_cookie(santa_auth_key,santa_auth_value) if User[params[:userid]].auth_user?(params[:password])
    redirect '/'
end

#get admin portal
get '/admin' do
    #TODO: Need admin portal template
    auth #FIXME: how does this work?
    user = User[params[:userid]]
    if user != nil and user.is_admin?() 
        ret = "You are an admin"
    else
        ret = "You are not an admin"
    end
    return ret
end

#create new santa path
post '/admin/create_santas' do
    #AJAXIFY ME, CAPTAIN
    #TODO: Santa path creation code
    #TODO: Insert santa path data into database
    #redirect '/admin'
end

post '/admin/email_users' do
    #TODO: Connect to SES & Email
    #TODO: Specify 
end

#get admin config panel
get '/admin/config' do
    #TODO: create admin config panel
    return "Admin config! WOO"
end

#set general config setting
#post '/admin/config/:setting' do

#get user portal
get '/user' do
    auth
    #TODO: create user portal template
    #FIXME: is this how getting a single record works?
    user = User[params[:userid]]
    return "Hello #{user.name}, here's a page just for you"
end

#get user creation template
get '/user/create' do 
    #TODO: user creation template
    return "user creation goes here"
end

#create user
post '/user/create' do
    user = User.new(:name => params[:name], :email => params[:email], :auth_credentials => User.digest_password(params[:password]))
    user.contact_info = params[:contact_info] if params.includes?(:contact_info)
    user.save()
    redirect "/user/#{user.id}"
end

#get user editing template
get '/user/edit/:userid' do |userid|
    auth
    #TODO: create user editing template
    # POST /user/edit/:property name|email|password
    # userid,value,(confirm if password)
    return "Edit your user"
end

#edit user data
post '/user/edit/:property' do |property|
    #AJAXIFY ME, CAPTAIN!
    auth
    user = User[params[:userid]]
    case property
    when "name"
        user.name = params[:value]
    when "email"
        user.email = params[:value]
    when "password"
        user.password = User.digest_password(params[:value]) if params[:value] == params[:confirm]
    else
        return "Error: invalid property"
    end
    if user.valid?() 
        user.save()
        return "Update successful"
    else
        return "Error: invalid data: #{user.errors}"
    end
end

#get couple portal
get '/couple' do
    auth
    #TODO: Create couple portal
    #   - list existing couples 
    Couple.all()
    return "Couples!"
end

#get couple creation template
get '/couple/create' do
    auth
    #FIXME: Should this be rolled in with get '/couple' ?
    #TODO: create couple creation template
    # - list all users not already coupled with :userid
    # - select a user & click "create couple" to create a couple
    couple_as_creator = Couple.where(:creator_userid => params[:userid]).all(:chimney_userid)
    couple_as_chimney = Couple.where(:chimney_userid => params[:userid]).all(:creator_userid)
    uncoupled_users = User.exclude(:id=>[couple_as_creator,couple_as_chimney]).all()
    return "Create couple between you and #{uncoupled_users}"
end

#set couple 
post '/couple/create' do
    #AJAXIFY ME, CAPTAIN
    auth
    #TODO: SELECT rec_count = 0 FROM (SELECT COUNT(1) as rec_count FROM Couple 
    #       WHERE (creator_userid = params[:userid] AND chimney_userid = params[:chimney_userid])
    #          OR (creator_userid = params[:chimney_userid] AND chimney_userid = params[:userid]))
    couple_exists = TODO
    unless couple_exists 
        couple = Couple.new(:creator_userid => params[:userid], :chimney_userid => params[:chimney_userid])
        couple.save
        return "Couple created"
    else
        return "Error: couple already exists!"
    end
end

#delete couple
post '/couple/delete' do
    #AJAXIFY ME, CAPTAIN
    #FIXME: can either member of a couple delete the couple?
    auth
    couple = Couple.filter(:id => params[:couple_id])
    if couple.creator_userid = params[:userid] or couple.chimney_userid = params[:userid] 
        couple.destroy()
        return "Couple deleted"
    else
        return "Error: you are not a member of that couple"
    end
end