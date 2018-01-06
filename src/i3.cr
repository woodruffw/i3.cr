require "./i3/*"

# An interface for the i3 window manager's IPC server.
module I3
  # A convenience method for quickly creating and disposing of a connection. Yields
  # a new `Connection`, and destroys it on block close.
  #
  # ```
  # I3.act do |con|
  #   # make the current window sticky
  #   con.command("sticky enable")
  # end
  # ```
  def self.act(&block)
    con = Connection.new
    yield con
    con.close
  end
end
