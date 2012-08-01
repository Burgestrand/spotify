# encoding: utf-8
module Spotify
  # An autopointer base class for Spotify pointers.
  #
  # It contains a default implementation for release, retain,
  # and a default constructor. When the underlying pointer is
  # garbage collected, the pointer is released automatically.
  #
  # @note The default ManagedPointer does not retain its pointer after initialization,
  #       but provides a class that does through {.retaining_class}. This is better as
  #       it allows you to err on the side of segfaulting, instead of leaking memory.
  class ManagedPointer < FFI::AutoPointer
    class << self
      # Releases the given pointer if it is not null.
      #
      # This method derives the release method from the class name.
      #
      # @param [FFI::Pointer] pointer
      def release(pointer)
        unless pointer.null?
          $stderr.puts "Spotify.#{type}_release(#{pointer.inspect})" if $DEBUG
          Spotify.public_send("#{type}_release", pointer)
        end
      end

      # Retains the given pointer if it is not null.
      #
      # This method derives the retain method from the class name.
      #
      # @param [FFI::Pointer] pointer
      def retain(pointer)
        unless pointer.null?
          $stderr.puts "Spotify.#{type}_add_ref(#{pointer.inspect})" if $DEBUG
          Spotify.public_send("#{type}_add_ref", pointer)
        end
      end

      # @return [self] subclass that retains its pointer on initialization.
      def retaining_class
        @klass ||= Class.new(self) do
          def initialize(*args, &block)
            superclass = self.class.superclass
            superclass.instance_method(:initialize).bind(self).call(*args, &block)
            superclass.retain(self)
          end

          class << self
            alias_method :==, :<=

            # @return [String] delegates to the superclass.
            def name
              superclass.name
            end

            # @return [String] delegates to the superclass.
            def to_s
              superclass.to_s
            end

            # @return [String] string representation of object
            def inspect
              "#{superclass}<retaining>"
            end
          end
        end
      end

      alias_method :==, :>=

      protected

      # @return [#to_s] the spotify type of this pointer.
      def type
        name.split('::')[-1].downcase
      end
    end

    # @return [String] string representation of self.
    def inspect
      "#<#{self.class} address=0x%x>" % address
    end

    alias_method :to_s, :inspect
  end
end
