class FFIHandler < YARD::Handlers::Ruby::Base
  include YARD::Tags
  
  handles method_call(:attach_function)
  
  process do
    # Extract parameters
    parameters = statement.parameters.children
    
    # Extract actual arguments
    parameters.unshift parameters[0] if parameters[1].type == :array
    
    # TODO: Resolve all arguments (if they are variables)
    
    # Normalize all arguments to string values
    literalizer = proc do |node|
      case node.type
      when :array # args: [:type, :type]
        node[0].map(&literalizer)
      when :fcall # callback([:type, :type], :type)
        name = node.jump(:ident)[0]
        args, rett = node.jump(:arg_paren)[0].children.map(&literalizer)
        "%s(%s):%s" % [name, args.join(', '), rett]
      else
        node.jump(:tstring_content, :ident)[0].sub("void", "nil")
      end
    end
    parameters.map!(&literalizer)
    
    # Now, we have all we need!
    name, cfunc, args, returns = parameters
    
    # Register the newly created method
    method = register MethodObject.new(namespace, name, :class)
    
    # Construct the final docstring
    overload = OverloadTag.new(:overload, "#{name}(#{args.join(', ')})")
    method.docstring.add_tag overload
    args.each do |type|
      overload.docstring.add_tag Tag.new(:param, nil, type)
    end
    overload.docstring.add_tag Tag.new(:return, nil, returns)
  end
end