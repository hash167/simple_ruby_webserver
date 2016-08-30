require 'socket'
SERVER_ROOT = Dir::pwd
 
server  = TCPServer.new('localhost', 8002)
 
class Response
  attr_accessor :code, :data
  def initialize(code:, data: "")
  	@code = code
  	@data = data
    "HTTP/1.1 #{code}\r\n" +
    "Content-Length: #{data.size}\r\n" +
    "\r\n" +
    "#{data}\r\n"
  end
  def code
  	@code
  end
  def send(client)
  	client.puts data
    client.write(@response)

  end
end
def parse request
	method, path, version = request.lines[0].split
	{
		path: path,
		method: method,
		headers: parse_headers(request)
	}
end
def normalize(header)
    header.gsub(":", "").downcase.to_sym
end
def parse_headers(request)
  headers = {}
 
  request.lines[1..-1].each do |line|
    return headers if line == "\r\n"
 
    header, value = line.split
    header        = normalize(header)
 
    headers[header] = value
  end
  
end 

def prepare_response(request)
  if request.fetch(:path) == "/"
    respond_with(SERVER_ROOT + "/index.html")
  else
    respond_with(SERVER_ROOT + request.fetch(:path))
  end
end
 
def respond_with(path)
  
  if File.exists?(path)
    send_ok_response(File.binread(path))
  else
    send_file_not_found
  end
end
def send_ok_response(data)
  Response.new(code: 200, data: data)
end
 
def send_file_not_found
  Response.new(code: 404)
end


loop {
  client  = server.accept
  request = client.readpartial(2048)

  request  = parse(request)
  response = prepare_response(request)
 
  puts "#{client.peeraddr[3]} #{request.fetch(:path)} - #{response.code}"
 
  response.send(client)
  client.close
 
  puts request
}