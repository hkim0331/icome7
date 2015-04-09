# sample to check mongo usage.

gem "mongo","1.12.1"
require "mongo"

@con = Mongo::Connection.new
@db  = @con['ucome']
@fri0 = @db['fri0']

