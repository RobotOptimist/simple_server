require 'socket'
require 'uri'
require 'json'


class Browser

def initialize
	@host = 'localhost'     # The web server
	@port = 3000            # Default localhost port
	@path = "./thanks.html" # The file we want 
end


def get_info
	puts "What is your viking's name?"
	name = gets.chomp
	puts "What is you viking's email address?"
	email = gets.chomp
	{:viking => {:name => name, :email=> email}}.to_json
end


def get_request 
	request = "GET #{@path} HTTP/1.0\r\n\r\n"
end

def post_request
	viking = get_info
	request = "POST #{@path} HTTP/1.0\r\n\r\n" +
						"Content-Length: #{viking.size}\r\n\r\n" +
						"#{viking}"
end

def offer_choice
	puts "Do you want to view the page or post information?"
	choice = gets.chomp
	case choice
	when "view" then get_request
	when "post" then post_request
	else 
		"I don't know what that means"
		offer_choice
	end
end

def connection(request)
	socket = TCPSocket.open(@host,@port)  # Connect to server
	socket.print(request)               # Send request
	response = socket.read              # Read complete response
	display(response)
end

def display(response)
	headers,body = response.split("\r\n\r\n", 2) 
	print body 
end                         # And display it

end