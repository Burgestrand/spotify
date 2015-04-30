describe "Spotify structs" do
  API_H_XML.structs.each do |struct|
    next if struct["incomplete"]

    attached_struct = Spotify.structs.find do |const|
      struct["name"].delete('_').match(/#{const}/i)
    end

    attached_members = Spotify.const_get(attached_struct).members.map(&:to_s)

    describe struct["name"] do
      it "should contain the same attributes in the same order" do
        struct.variables.map(&:name).each_with_index do |member, index|
          expect(attached_members[index]).to eq member
        end
      end
    end
  end
end
