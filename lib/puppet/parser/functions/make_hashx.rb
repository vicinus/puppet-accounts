Puppet::Parser::Functions::newfunction(:make_hashx, :type => :rvalue, :doc => <<-EOS
converts an array of hashes to a hash of hashes with a special key generated
from catting 
EOS
) do |args|
  raise ArgumentError, ("make_hashx(): wrong number of arguments (#{args.length}; must be 1)") if args.length > 1
  raise ArgumentError, ('make_hashx(): first argument must be a array') unless args[0].is_a?(Array)
  iarray = args[0]

  res = {} 
  iarray.each do |item|
    if item.is_a?(Hash)
      res.merge!(item)
    else
      res[item] = {}
    end
  end
  return res
end
