$dev_debug = true
$dev_random = Random.new.hash
load 'harvester_parser.rb'

# reload! ; load 'vets.rb' ; g = parsevets ; g.count

#  h = Scan.find_by(url:"/19").html.css('td.content_table').css('p'); 7

class Harvester
  @@site_name = nil
  @@filters = []
  @@crops = []
  
  def self.filters
    @@filters
  end
  
  def self.filter only_for: nil, regex: nil, rule: :allow, &block
    if block
      raise "cannot have both regex and block in same filter" if regex
      filter_proc = block
    else
      filter_proc = Proc.new { url.match regex }
    end
    @@filters << { 
      only_for: [only_for],
      rule: rule, # it can also be deny, and such must be defined before allow
      block: filter_proc
    }
  end
  
  def self.harvest name: nil, &block
    raise "you should define site name before defining a harvest" unless @@site_name
    @@crops << {
      name: name || @@site_name,
      block: block
      }
  end
  
  def self.perform_harvest name: nil
    raise "you should define site name before trying harvesting." unless @@site_name
    name ||= @@site_name
    current_harvest = @@crops.collect{|x| x[:name] == name}[0]
    raise "nothing to harvest. Define a harvest before performing it." unless current_harvest
    
    Site[@@site_name].scans.scrape do |scan|
      Thread.current.thread_variable_set('scan', scan)
      if do_filter scan, filter_for: :harvesting
        puts "harvesting #{scan.url}" if $dev_debug
      end
    end
  end
  
  private
  
  def self.do_filter scan, filter_for: :anything
    @@filters.each do |f|
      if filter_for == :anything or 
          f[:only_for].include? :always or
          f[:only_for].include? filter_for
        if check? { scan.instance_exec &f[:block] }
          return f[:rule] == :allow
          # above line will return false if rule is :deny (or anything else)
        end
      end
    end
    false
  end
end