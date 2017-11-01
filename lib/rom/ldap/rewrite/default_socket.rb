
class DefaultSocket

  def self.new(host, port, socket_opts = {})
    Socket.tcp(host, port, socket_opts)
  end

end
