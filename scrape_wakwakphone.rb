require 'net/http'

if ARGV.size != 2
  puts "ruby scrape_wakwakphone.rb url_from_e_mail password\n"
  exit 0
end

first_url = String.new ARGV[0]
onetime_password = ARGV[1]

first_url.sub!(/^(.*)\/xcpvcs\/index\.html\?\(.*\)$/, '\1/servlet/IADURLParseAndSetServlet\2')
first_uri = URI(first_url)

auth_url = 'https://cust.lmc.xephion.ne.jp:48443/xcpvcs/servlet/IADAuthenticateAndSetServlet'
auth_uri = URI(auth_url)

def exec_request(uri, req)
  res = nil

  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    res = http.request(req)
    p "==========================="
    req.each_header do |k, v|
      p "#{k} : #{v}"
    end
    p "---------------------------"
    res.each_header do |k, v|
      p "#{k} : #{v}"
    end
    p "---------------------------"
  end

  res
end


req = Net::HTTP::Get.new(first_uri.request_uri)

req['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'
req['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
req['Accept-Encoding'] = 'gzip,deflate,sdch'
req['Accept-Language'] = 'en-US,en;q=0.8'
req['Accept-Charset'] = 'ISO-8859-1,utf-8;q=0.7,*;q=0.3'

res = exec_request(first_uri, req)
cookie = res.response['set-cookie'].split('; ')[0]


req = Net::HTTP::Post.new(auth_uri.path)

req.set_form_data('password' => onetime_password)
req['Content-Type'] = 'application/x-www-form-urlencoded'
req['Cookie'] = cookie
req['Referer'] = first_url
req['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'
req['Origin'] = "#{first_uri.scheme}://#{first_uri.hostname}:#{first_uri.port}"

res = exec_request(auth_uri, req)

res.body.split(/[\n\r]+/).each do |line|
  puts "#{line}\n"
end



