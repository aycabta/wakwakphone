
require 'webrick'

srv = WEBrick::HTTPServer.new({
  :DocumentRoot => './',
  :Port => 8989
})
srv.mount_proc('/voip_setup.cgi') do |req, res|
  q = req.query
  p 'sip: ' + q['ip_tel_num'] + '@' + q['sip_domain']
  p 'server address: ' + q['sipsv_addr']
  p 'user ID: ' + q['username']
  p 'password: ' + q['password']
end

trap('INT') { srv.shutdown }

srv.start

