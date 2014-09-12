require 'socket'      # Sockets are in standard library

hostname = 'localhost'
port = 3000

s = TCPSocket.open(hostname, port)

request = 'quit'
s.print request

s.close               # Close the socket when done