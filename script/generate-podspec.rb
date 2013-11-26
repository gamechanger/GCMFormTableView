require 'erubis'

template = File.read(File.dirname(__FILE__) + "/GCMFormTableView.podspec.erb")
template = Erubis::Eruby.new(template)
puts template.result(:version => ARGV[0])

