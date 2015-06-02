module Puppet::Parser::Functions
  newfunction(:debug_hash, :type => :rvalue) do |args|
    raise Puppet::Error, "debug_hash requires 1 argument; got #{args.length}" if args.length != 1
    return args[0].inspect
  end
end
