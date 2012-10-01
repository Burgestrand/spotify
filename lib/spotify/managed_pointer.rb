# encoding: utf-8
module Spotify
  # An autopointer base class for Spotify pointers.
  #
  # It contains a default implementation for release, retain,
  # and a default constructor. When the underlying pointer is
  # garbage collected, the pointer is released automatically.
  #
  # This class is never instantiated; instead you’ll be dealing
  # with any of it’s subclasses.
  #
  # @note The default ManagedPointer does not retain its pointer after initialization,
  #       but provides a class that does through {.retaining_class}. This is better as
  #       it allows you to err on the side of segfaulting, instead of leaking memory.
  #
  # @api private
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

      # Retaining class is needed for the functions that return a pointer that
      # does not have its reference count increased. This class is a subclass
      # of the ManagedPointer, and should behave the same in all circumstances
      # except for during initialization.
      #
      # This dynamic method is needed to DRY the pointers up. We have about ten
      # subclasses of ManagedPointer; all of them need a subclass that retains
      # its pointer on initialization. We could create one manually for each
      # Album, Artist, Track, and so on, but that would be annoying.
      #
      # @return [self] subclass that retains its pointer on initialization.
      def retaining_class
        if defined?(self::Retaining)
          self::Retaining
        else
          subclass = Class.new(self) do
            class << self
              def type
                superclass.type
              end
            end

            def initialize(*)
              super
              self.class.retain(self)
            end
          end

          const_set("Retaining", subclass)
        end
      end

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
