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
        error_class = @@code_to_class.fetch(error) do
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

      def error_code(number)
        @to_i = number
        @@code_to_class[number] = self
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

  class BadAPIVersionError < APIError
    error_code 1
  end

  class APIInitializationFailedError < APIError
    error_code 2
  end

  class TrackNotPlayableError < APIError
    error_code 3
  end

  class BadApplicationKeyError < APIError
    error_code 5
  end

  class BadUsernameOrPasswordError < APIError
    error_code 6
  end

  class UserBannedError < APIError
    error_code 7
  end

  class UnableToContactServerError < APIError
    error_code 8
  end

  class ClientTooOldError < APIError
    error_code 9
  end

  class OtherPermanentError < APIError
    error_code 10
  end

  class BadUserAgentError < APIError
    error_code 11
  end

  class MissingCallbackError < APIError
    error_code 12
  end

  class InvalidIndataError < APIError
    error_code 13
  end

  class IndexOutOfRangeError < APIError
    error_code 14
  end

  class UserNeedsPremiumError < APIError
    error_code 15
  end

  class OtherTransientError < APIError
    error_code 16
  end

  class IsLoadingError < APIError
    error_code 17
  end

  class NoStreamAvailableError < APIError
    error_code 18
  end

  class PermissionDeniedError < APIError
    error_code 19
  end

  class InboxIsFullError < APIError
    error_code 20
  end

  class NoCacheError < APIError
    error_code 21
  end

  class NoSuchUserError < APIError
    error_code 22
  end

  class NoCredentialsError < APIError
    error_code 23
  end

  class NetworkDisabledError < APIError
    error_code 24
  end

  class InvalidDeviceIdError < APIError
    error_code 25
  end

  class CantOpenTraceFileError < APIError
    error_code 26
  end

  class ApplicationBannedError < APIError
    error_code 27
  end

  class OfflineTooManyTracksError < APIError
    error_code 31
  end

  class OfflineDiskCacheError < APIError
    error_code 32
  end

  class OfflineExpiredError < APIError
    error_code 33
  end

  class OfflineNotAllowedError < APIError
    error_code 34
  end

  class OfflineLicenseLostError < APIError
    error_code 35
  end

  class OfflineLicenseError < APIError
    error_code 36
  end

  class LastfmAuthError < APIError
    error_code 39
  end

  class InvalidArgumentError < APIError
    error_code 40
  end

  class SystemFailureError < APIError
    error_code 41
  end
end
