require 'socket'               # Get sockets from stdlib
require 'uri'
require 'json'

#thank you https://practicingruby.com/articles/implementing-an-http-file-server

WEB_ROOT = './'

CONTENT_TYPE_MAPPING = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}

DEFAULT_CONTENT_TYPE = 'application/octet-stream'

def content_type(path)
  ext = File.extname(path).split(".").last
  CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end


def requested_file(request_line)
  request_uri  = request_line.split(" ")[1]
  path = URI.unescape(URI(request_uri).path)

  clean = []

  parts = path.split("/")

  parts.each do |part|
    next if part.empty? || part == '.'
    part == '..' ? clean.pop : clean << part
  end

  File.join(WEB_ROOT, *clean)
end

def method(request_line)
	lines = request_line.split(" ")
	lines[0]
end

def body(request_line)
	arr = request_line.split("\r\n\r\n")
	body = arr[2]
	body
end

server = TCPServer.new('localhost',3000)  # Socket to listen on port 2000

loop do
  socket = server.accept
  request_line = socket.read_nonblock(256)

  STDERR.puts request_line
	
	command = method(request_line)
	
	break if request_line == 'quit'
	
  path = requested_file(request_line)
	
  if File.exist?(path) && !File.directory?(path)
		if command == "GET"
			File.open(path, "rb") do |file|
				socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: #{content_type(file)}\r\n" +
                   "Content-Length: #{file.size}\r\n" +
                   "Connection: close\r\n"

				socket.print "\r\n"

				# write the contents of the file to the socket
				IO.copy_stream(file, socket)
			end
		elsif command == "POST"
				request_body = body(request_line)
				params = JSON.parse(request_body)
        user_data = "<li>name: #{params['viking']['name']}</li><li>e-mail: #{params['viking']['email']}</li>"
				response_body = File.read(path)
				socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: #{content_type(response_body)}\r\n" +
                   "Content-Length: #{response_body.size}\r\n" +
                   "Connection: close\r\n"

				socket.print "\r\n"

				# write the contents of the file to the socket
				socket.puts response_body.gsub('<%= yield %>', user_data)
		end
  else
    message = "File not found\n"

    # respond with a 404 error code to indicate the file does not exist
    socket.print "HTTP/1.1 404 Not Found\r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{message.size}\r\n" +
                 "Connection: close\r\n"

    socket.print "\r\n"

    socket.print message
  end

  socket.close
end