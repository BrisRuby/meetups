require 'active_record'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: 'ar.sqlite3'