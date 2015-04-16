#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# プログラムのバグのため、{sid: "sid", attends: [ "2015-04-15" ]} という
# ドキュメントが作られてしまった。
# そいつを {sid: "sid", attends: ["2015-04-08"]} に $addToSet してから消す。
# 

gem "mongo","1.12.1"
require "mongo"

@conn = Mongo::Connection.new("localhost","27017")
@db   = @conn["ucome"]
["15109008", "15109046" "15104138", "15104113"].each do |sid|
  @db["a2015"].update({sid: sid, attends: ["2015-04-08"]},{"$addToSet" => {attends: "2015-04-15"}})
end

["15109008", "15109046" "15104138", "15104113"].each do |sid|
  @db["a2015"].remove({sid: sid, attends: ["2015-04-15"]})
end
