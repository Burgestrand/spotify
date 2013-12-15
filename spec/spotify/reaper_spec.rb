require "thread"
require "timeout"

describe Spotify::Reaper, :reaper do
  # Our spec helper creates a new reaper for each spec, we are fine.
  let(:reaper) { Spotify::Reaper.instance }
  let(:pointer) { double("pointer", free: nil) }
  let(:timeout) { 0.3 }

  it "logs an error if the reaper dies somehow" do
    Spotify.should_receive(:log).with(/Reaper#mark/).ordered
    Spotify.should_receive(:log).with(/Reaper WAS KILLED: .*\bHoola hoop\b.*/).ordered
    pointer.should_receive(:free).and_raise(RuntimeError.new("Hoola hoop"))

    reaper.mark(pointer)

    expect { reaper.reaper_thread.join(timeout) }.to raise_error(/Hoola hoop/)
    reaper.reaper_thread.should_not be_alive
  end

  describe "#mark" do
    it "marks the pointer for garbage collection on the next Reaping" do
      queue = Queue.new
      pointer.should_receive(:free).and_return { queue << :ok }

      reaper.mark(pointer)

      Timeout.timeout(timeout) { queue.pop }
    end

    it "logs a message on success" do
      Spotify.should_receive(:log).with(/Reaper#mark\([^)]+\)$/).ordered
      reaper.mark(pointer)
    end

    it "logs an error if reaper is not running" do
      reaper.terminate!

      Spotify.should_receive(:log).with(/Reaper is dead. Cannot mark/)
      reaper.mark(pointer)
    end
  end

  describe "#terminate" do
    it "returns false if termination did not occur within time" do
      reaper.reaper_thread.should_receive(:join).and_return(nil) # instantly!
      reaper.terminate.should be_false
    end

    it "can be called multiple times without raising an error" do
      reaper.terminate.should be_true
      reaper.terminate.should be_true
    end

    it "raises an error if trying to wait forever" do
      expect { reaper.terminate(nil) }.to raise_error(Spotify::Error, /risk of race condition/)
      expect { reaper.terminate(0) }.to raise_error(Spotify::Error, /risk of race condition/)
    end
  end

  describe "#terminate!" do
    it "raises an error if termination did not occur within time" do
      reaper.reaper_thread.should_receive(:join).and_return(nil) # instantly!
      expect { reaper.terminate! }.to raise_error(Spotify::Error, /Reaper did not terminate/)
    end
  end
end
