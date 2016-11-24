require 'date'
require 'sequel'
require 'digest/sha2'

class User < Sequel::Model
    plugin :schema
    if not table_exists?() 
        set_schema() do
            primary_key(:id)
            column(:name, :text, :empty => false)
            column(:email, :text, :empty => false)
            column(:access_level, :text, :empty => false, :default => 'User')
            column(:contact_info, :text)
            column(:auth_credentials, :text, :empty => false)
        end
        create_table()
    end
    
    def self.digest_password(password) 
        #FIXME: THIS IS TERRIBLE! DO NOT COMMIT SALTS!
        return Digest::SHA256.hexdigest('awfulsalt' + password)
    end
    
    def auth_user?(password) 
        return digest_password(password) == auth_credentials
    end
    
    def is_admin?() 
        return access_level == 'Admin'
    end
    
end

class SantaEvent < Sequel::Model
    plugin :schema
    if not table_exists?() 
        set_schema() do
            primary_key(:id)
            column(:date_start, :date, :empty => false)
            column(:date_end, :date, :empty => false)
            column(:date_deadline, :date, :empty => false)
            column(:spend_limit, :float)
            column(:metadata, :text)
        end
        create_table()
    end
    
    def days_to_deadline()
        now = Date.today()
        return Integer(date_deadline - now)
    end
end

class SantaPath < Sequel::Model
    plugin :schema
    if not table_exists?() 
        set_schema() do
            primary_key(:id)
            foreign_key(:santaeventid,:santaevent,:key=>:id)
            foreign_key(:santa_userid,:user,:key=>:id)
            foreign_key(:chimney_userid,:user,:key=>:id)
        end
        create_table()
    end
    
    def self.get_full_path(eventid) 
        #FIXME: provide full path
        return [0] 
    end
end
   
   
class Couple < Sequel::Model
    plugin :schema
    if not table_exists?() 
        set_schema() do
            primary_key(:id)
            foreign_key(:creator_userid,:user,:key=>:id)
            foreign_key(:chimney_userid,:user,:key=>:id)
        end
        create_table()
    end
end