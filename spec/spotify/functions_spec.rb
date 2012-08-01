describe "Spotify functions" do
  API_H_XML.functions.each do |func|
    next unless func["name"] =~ /\Asp_/
    attached_name = func["name"].sub(/\Asp_/, '')

    def type_of(type, return_type = false)
      return case type.to_cpp
        when "const char*"
          Spotify::UTF8String
        when /\A(::)?(char|int|size_t|bool|sp_scrobbling_state|sp_session\*|byte)\*/
          return_type ? :pointer : :buffer_out
        when /::(.+_cb)\*/
          $1.to_sym
        when /::(\w+)\*\*/
          :array
        when /::sp_(\w+)\*/
          const_name = $1.delete('_')
          real_const = Spotify.constants.find { |const| const =~ /#{const_name}\z/i }
          Spotify.const_get(real_const)
        else
          :pointer
      end if type.is_a?(RbGCCXML::PointerType)

      case type["name"]
      when "unsigned int"
        :uint
      else
        type["name"].sub(/\Asp_/, '').to_sym
      end
    end

    # We test several things in this test because if we make the assertions
    # into separate tests there’s just too much noise on failure.
    specify(func["name"]) do
      # it should be attached
      Spotify.should respond_to attached_name

      # expect the correct number of arguments
      Spotify.attached_methods[attached_name][:args].count.
        should eq func.arguments.count

      # each argument has the right type
      current = Spotify.attached_methods[attached_name][:args]
      actual  = func.arguments.map { |arg| type_of(arg.cpp_type) }

      current = current.map { |x| Spotify.resolve_type(x) }
      actual  = actual.map  { |x| Spotify.resolve_type(x) }

      current.should eq actual

      # returns the correct type
      current_type = Spotify.attached_methods[attached_name][:returns]
      actual_type  = type_of(func.return_type, true)

      # loosen restraints on some return types, we don’t have enough info from header file
      current_type = Spotify.resolve_type(current_type)
      actual_type  = Spotify.resolve_type(actual_type)

      current_type.should eq actual_type
    end
  end
end
