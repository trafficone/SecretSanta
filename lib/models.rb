require 'date'
require 'sequel'
require 'digest/sha256'

class User < Sequel::Model
    if not table_exists?() do
        set_schema() do
            primary_key(:id)
            column(:name, :string, :empty => false)
            column(:email, :string, :empty => false
            column(:access_level, :string, :empty => false, :default => 'User')
            column(:contact_info, :string)
            column(:auth_credentials, :string, :empty => false)
        end
        create_table()
    end
    
    def self.digest_password(password) do
        #FIXME: THIS IS TERRIBLE! DO NOT COMMIT SALTS!
        return Digest::SHA256.hexdigest('awfulsalt' + password)
    end
    
    def auth_user?(password) do
        return digest_password(password) == auth_credentials
    end
    
    def is_admin?() do
        return access_level == 'Admin'
    end
    
end

class SantaEvent < Sequel::Model
    if not table_exists?() do
        set_schema() do
            primary_key(:id)
            column(:date_start, :date, :empty => false)
            column(:date_end, :date, :empty => false
            column(:date_deadline, :date, :empty => false
            column(:spend_limit, :integer)
            column(:metadata)
        end
        create_table()
    end
    
    def days_to_deadline()
        now = Date.today()
        return Integer(date_deadline - now)
    end
end

class SantaPath < Sequel::Model
    if not table_exists?() do
        set_schema() do
            primary_key(:id)
            foreign_key(:santaeventid,:santaevent,:key=>:id)
            foreign_key(:santa_userid,:user,:key=>:id)
            foreign_key(:chimney_userid,:user,:key=>:id)
        end
        create_table()
    end
    
    def self.get_full_path(eventid) do
        
    end
end
    
class Couples < Sequel::Model
    if not table_exists?() do
        set_schema() do
            primary_key(:id)
            foreign_key(:creator_userid,:user,:key=>:id)
            foreign_key(:chimney_userid,:user,:key=>:id)
        end
        create_table()
    end
end