Puppet::Parser::Functions::newfunction(:make_hash, :type => :rvalue, :doc => <<-EOS
converts an array of hashes to a hash of hashes with a special key generated
from catting 
EOS
) do |args|
  raise ArgumentError, ("make_hash(): wrong number of arguments (#{args.length}; must be 1 to 3)") if args.length > 2
  raise ArgumentError, ('make_hash(): first argument must be a array') unless args[0].is_a?(Array)
  iarray = args[0]
  if args.length == 2
    if args[1].is_a? String
      keyprefix = "#{args[1]}_"
      keyname = false
      options = {}
    else
      options = args[1]
      if options.has_key?('keyprefix')
        keyprefix = "#{options['keyprefix']}_"
      else
        keyprefix = ''
      end
      if options.has_key?('keyname')
        keyname = options['keyname']
      else
        keyname = false
      end
    end
  else
    keyprefix = ''
    keyname = false
    options = {}
  end

  res = {} 
  iarray.each_with_index do |item, index|
    if item.is_a? String
      keyvalue = item
      if options.has_key?('hiera_key')
        #item = call_function('hiera_hash', [options['hiera_key'].gsub(/%k/, keyvalue), {}])
       item = call_function('lookup', [options['hiera_key'].gsub(/%k/, keyvalue), Puppet::Type.type(Hash), 'deep', {}])
      else
        item = {}
      end
    else
      if keyname and item.has_key?(keyname)
        keyvalue = item[keyname]
      else
        keyvalue = index
      end
    end
    key = "#{keyprefix}#{keyvalue}"
    if res.has_key?(key) and options.has_key?('merge_items')
      res[key] = function_accounts_deepmerge([res[key], item])
    else
      res[key] = item
    end
  end
  return res
end
