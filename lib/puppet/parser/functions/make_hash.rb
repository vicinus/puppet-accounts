Puppet::Parser::Functions::newfunction(:make_hash, :type => :rvalue, :doc => <<-EOS
converts an array of hashes to a hash of hashes with a special key generated
from catting 
EOS
) do |args|
  raise ArgumentError, ("make_hash(): wrong number of arguments (#{args.length}; must be 2 or 3)") if args.length > 3
  raise ArgumentError, ('make_hash(): first argument must be a array') unless args[0].is_a?(Array)
  iarray = args[0]
  ikeyprefix = args[1]
  ikeyparam = args[2]

  res = {} 
  iarray.each_with_index do |item, index|
    if args.length == 3
      keyvalue = item[args[2]]
    else
      keyvalue = index
    end
    key = "#{ikeyprefix}#{keyvalue}"
    res[key] = item
  end
  return res
end
