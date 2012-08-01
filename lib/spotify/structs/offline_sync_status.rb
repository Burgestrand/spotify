class SpotifyAPI
  # SpotifyAPI::Struct for Offline Sync Status
  #
  # @attr [Fixnum] queued_tracks
  # @attr [Fixnum] queued_bytes
  # @attr [Fixnum] done_tracks
  # @attr [Fixnum] done_bytes
  # @attr [Fixnum] copied_tracks
  # @attr [Fixnum] copied_bytes
  # @attr [Fixnum] willnotcopy_tracks
  # @attr [Fixnum] error_tracks
  # @attr [Boolean] syncing
  class OfflineSyncStatus < SpotifyAPI::Struct
    layout :queued_tracks => :int,
           :queued_bytes => :uint64,
           :done_tracks => :int,
           :done_bytes => :uint64,
           :copied_tracks => :int,
           :copied_bytes => :uint64,
           :willnotcopy_tracks => :int,
           :error_tracks => :int,
           :syncing => :bool
  end
end
