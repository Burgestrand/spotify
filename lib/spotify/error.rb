module Spotify
  # A generic error class for Spotify errors.
  class Error < StandardError
  end

  # @abstract Generic error class, extended by all libspotify errors.
  class APIError < Spotify::Error
    extend FFI::DataConverter
    native_type :int

    @@code_to_class = { 0 => nil }

    class << self
      # Returns an error if applicable.
      #
      # @param [Integer] error
      # @return [Error, nil] an error, unless error symbol was OK
      def from_native(error, context)
        error_class = code_to_class.fetch(error) do
          raise ArgumentError, "unknown error code: #{error}"
        end
        error_class.new if error_class
      end

      # From an error, retrieve it's native value.
      #
      # @param [Error] error
      # @return [Symbol]
      def to_native(error, context)
        if error
          error.to_i
        else
          0
        end
      end

      # @return [Integer] error code
      attr_reader :to_i

      private

      def code_to_class
        @@code_to_class
      end
    end

    # @param [String] message only to be supplied if overridden
    def initialize(message = "#{Spotify::API.error_message(self)} (#{to_i})")
      super
    end

    # @return (see .to_i)
    def to_i
      self.class.to_i
    end
  end

  class << self
    private

    # @!macro [attach] define_error
    #   @!parse class $1 < Spotify::APIError; end
    def define_error(name, number)
      const_set(name, Class.new(Spotify::APIError) do
        code_to_class[number] = self
        @to_i = number
      end)
    end
  end

  define_error("BadAPIVersionError", 1)
  define_error("APIInitializationFailedError", 2)
  define_error("TrackNotPlayableError", 3)
  define_error("BadApplicationKeyError", 5)
  define_error("BadUsernameOrPasswordError", 6)
  define_error("UserBannedError", 7)
  define_error("UnableToContactServerError", 8)
  define_error("ClientTooOldError", 9)
  define_error("OtherPermanentError", 10)
  define_error("BadUserAgentError", 11)
  define_error("MissingCallbackError", 12)
  define_error("InvalidIndataError", 13)
  define_error("IndexOutOfRangeError", 14)
  define_error("UserNeedsPremiumError", 15)
  define_error("OtherTransientError", 16)
  define_error("IsLoadingError", 17)
  define_error("NoStreamAvailableError", 18)
  define_error("PermissionDeniedError", 19)
  define_error("InboxIsFullError", 20)
  define_error("NoCacheError", 21)
  define_error("NoSuchUserError", 22)
  define_error("NoCredentialsError", 23)
  define_error("NetworkDisabledError", 24)
  define_error("InvalidDeviceIdError", 25)
  define_error("CantOpenTraceFileError", 26)
  define_error("ApplicationBannedError", 27)
  define_error("OfflineTooManyTracksError", 31)
  define_error("OfflineDiskCacheError", 32)
  define_error("OfflineExpiredError", 33)
  define_error("OfflineNotAllowedError", 34)
  define_error("OfflineLicenseLostError", 35)
  define_error("OfflineLicenseError", 36)
  define_error("LastfmAuthError", 39)
  define_error("InvalidArgumentError", 40)
  define_error("SystemFailureError", 41)
end
