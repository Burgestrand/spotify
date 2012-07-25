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
        when /::sp_(\w+)\*/
          const_name = $1.delete('_')
          real_const = Spotify.constants.find { |const| const =~ /#{const_name}/i }
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

    describe func["name"] do
      it "should be attached" do
        Spotify.should respond_to attached_name
      end

      it "should expect the correct number of arguments" do
        Spotify.attached_methods[attached_name][:args].count.
          should eq func.arguments.count
      end

      it "should return the correct type" do
        current = Spotify.attached_methods[attached_name][:returns]
        actual  = type_of(func.return_type, true)

        if actual.is_a?(Class) and actual <= Spotify::ManagedPointer
          actual.should >= current
        else
          Spotify.resolve_type(current).should eq Spotify.resolve_type(actual)
        end
      end

      it "should expect the correct types of arguments" do
        current = Spotify.attached_methods[attached_name][:args]
        actual  = func.arguments.map { |arg| type_of(arg.cpp_type) }

        current = current.map { |x| Spotify.resolve_type(x) }
        actual  = actual.map  { |x| Spotify.resolve_type(x) }

        current.should eq actual
      end
    end
  end
end
