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
    extend Spotify::TypeSafety

    class << self
      # Schedules given pointer for release.
      #
      # @param [FFI::Pointer] pointer
      def release(pointer)
        unless pointer.null?
          # this is to circumvent the type protection, and wrap the pointer
          # with the correct type for later freeing
          freeable = type_class.new(pointer)
          # and this is to not make this pointer trigger release again
          freeable.autorelease = false

          Spotify.performer.async { freeable.free }
        end
      end

      # Retains the given pointer if it is not null.
      #
      # This method derives the retain method from the class name.
      #
      # @param [self] pointer must be an instance of {#type_class}
      def retain(pointer)
        unless pointer.null?
          Spotify.log "Spotify.#{type}_add_ref(#{pointer.inspect})"
          Spotify.public_send(:"#{type}_add_ref", pointer)
        end
      end

      # Makes all ManagedPointers typesafe in the sense that they will raise
      # an argument error on any value that is not of the same kind.
      def to_native(value, ctx)
        if value.nil? or value.null?
          raise TypeError, "#{name} pointers cannot be null, was #{value.inspect}"
        else
          super
        end
      end

      # Casts all null pointers to nil.
      def from_native(pointer, ctx)
        value = super
        value unless value.null?
      end

      # @see https://github.com/jruby/jruby/issues/607
      # @return [Integer] size of the native type, defined for JRuby.
      def size
        FFI.type_size(:pointer)
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

              protected

              def type_class
                superclass
              end
            end

            alias_method :super_initialize, :initialize
            def initialize(*args, &block)
              super_initialize(*args, &block)
              self.class.retain(self)
            end
          end

          const_set("Retaining", subclass)
        end
      end

      # Retrieves the normalized and downcased name of self, so for
      # Spotify::Album we’ll receive just “album”.
      def type
        name.split('::')[-1].downcase
      end
    end

    # @see self.class.type
    def type
      self.class.type
    end

    # Immediately releases the underlying pointer.
    #
    # @note Does NOT call self.class.release.
    # @note This is NOT idempotent.
    def free
      unless null?
        self.autorelease = false
        Spotify.log "Spotify.#{type}_release(#{inspect})"
        Spotify.public_send(:"#{type}_release", self)
      end
    end

    # @return [String] string representation of self.
    def inspect
      "#<#{self.class} address=0x%x>" % address
    end

    alias_method :to_s, :inspect
  end
end
