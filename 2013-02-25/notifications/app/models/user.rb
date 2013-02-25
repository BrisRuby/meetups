class User < ActiveRecord::Base
  attr_accessible :name, :token

  def self.create_new(login)
    User.create do |u|
      u.name = login
      u.token = SecureRandom.hex
    end
  end

  def update_token
    self.token = SecureRandom.hex
    self.save
  end

  def queue
    "/queue/#{self.name}_#{self.token}"
  end

  def welcome
    hash = {
      :hosts => [
        # First connect is to remotehost1
        {:login => "system", :passcode => "manager", :host => "localhost", :port => 61612, :ssl => false},
      ],

      # These are the default parameters and do not need to be set
      :reliable => true,                  # reliable (use failover)
      :initial_reconnect_delay => 0.01,   # initial delay before reconnect (secs)
      :max_reconnect_delay => 30.0,       # max delay before reconnect
      :use_exponential_back_off => true,  # increase delay between reconnect attpempts
      :back_off_multiplier => 2,          # next delay multiplier
      :max_reconnect_attempts => 0,       # retry forever, use # for maximum attempts
      :randomize => false,                # do not radomize hosts hash before reconnect
      :connect_timeout => 0,              # Timeout for TCP/TLS connects, use # for max seconds
      :connect_headers => {},             # user supplied CONNECT headers (req'd for Stomp 1.1+)
      :parse_timeout => 5,                # receive / read timeout, secs
      :logger => nil,                     # user suplied callback logger instance
      :dmh => false,                      # do not support multihomed IPV4 / IPV6 hosts during failover
      :closed_check => true,              # check first if closed in each protocol method
      :hbser => false,                    # raise on heartbeat send exception
      :stompconn => false,                # Use STOMP instead of CONNECT
      :usecrlf => false,                  # Use CRLF command and header line ends (1.2+)
    }

    # for client
    client = Stomp::Client.new(hash)
    client.publish(self.queue, "Welcome")
    client.publish(self.queue, "Welcome")
    client.publish(self.queue, "Welcome")
    client.publish(self.queue, "Welcome")
  end
end
