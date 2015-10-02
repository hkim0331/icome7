require 'json'

INFILE = "2015-10-02.csv"
OUTFILE= "2015-10-02-fixed.csv"

PREFIX = {'j'=>'10', 'k'=>'11', 'm'=>'12', 'n'=>'13', 'o'=>'14', 'p'=>'15'}
def uid2sid(uid)
  PREFIX[uid[0]] + uid[1,6]
rescue
  uid
end

File.open(OUTFILE,"w") do |of|
  File.foreach(INFILE) do |line|
    data = JSON.parse(line)
    uid = data["sid"]
    data["sid"] = uid2sid(uid)
    of.puts data.to_json
  end
end
