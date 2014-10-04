the_xml = File.open("RenewalReports.XML")
datas = Nokogiri::XML(the_xml)
nodes = datas.xpath("ns1:application_groups/ns1:application_group", {ns1: 'http://openhbx.org/api/terms/1.0'})

nodes.each do |node|
  parser = Parsers::Xml::Cv::ApplicationGroup.new(node)
  parser.to_request
end
