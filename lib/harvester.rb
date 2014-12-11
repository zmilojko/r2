# -*- coding: UTF-8 -*-

$dev_debug = true
$dev_random = Random.new.hash
if $dev_debug
  load 'harvester_parser.rb'
else
  require 'harvester_parser'
end
# reload! ; load 'vets.rb' ; g = parsevets ; g.count
# reload! ; load 'vets.rb' ; k = Vet.perform_harvest ; k.count

#  h = Scan.find_by(url:"/19").html.css('td.content_table').css('p'); 7

class Harvester
  @@site_name = nil
  @@filters = []
  @@crops = []
  
  def self.site site_name
    @@site_name = site_name
  end

  def self.filters
    @@filters
  end
  
  def self.filter only_for: :always, regex: nil, rule: :allow, &block
    if block
      raise "cannot have both regex and block in same filter" if regex
      filter_proc = block
    else
      filter_proc = Proc.new { url.match regex }
    end
    @@filters << { 
      only_for: [only_for].flatten,
      rule: rule, # it can also be deny, and such must be defined before allow
      block: filter_proc
    }
  end
  
#     find css: 'td.content_table' do # as: :td
#       find css: 'p' # as :p', note that this is inside :td block
#     end
  
  def self.harvest name: nil, &block
    raise "you should define site name before defining a harvest" unless @@site_name
    processor = FindProcessor.new block: block
    processor.execute
    @@crops << {
        name: name || @@site_name,
        block: block,
        finds: processor.finds(),
        scrapers: processor.scrapers
      }
  end
  
  def self.perform_harvest name: nil
    raise "you should define site name before trying harvesting." unless @@site_name
    name ||= @@site_name
    current_harvest = @@crops[@@crops.index{|x| x[:name] == name}]
    raise "nothing to harvest. Define a harvest before performing it." unless current_harvest
    results = []
    
    site = Site[@@site_name]
    sort = nil
    
    site.scans.each do |scan|
      if do_filter scan, filter_for: :harvesting
        new_results = harvest_for harvest: current_harvest, name: 'document', node: scan.html
        results.push *new_results
        # this is a good place to save
        new_results.select! { |r| r[:object] }
        new_results.map! do |r|
          sort = r[:sort]
          r[:object]
        end
        site.crops.create! new_results
      end
    end
    
    
    results.select! { |r| r[:object] }
    results.map! do |r|
      sort = r[:sort]
      r[:object]
    end
    raise "currently can sort only by one field!" unless sort.length == 1
    results.sort_by! {|r| r[sort[0]]} if sort
    results
  end
  
  private
  
  def self.harvest_for harvest: nil, name: nil, node: nil, found_nodes_hash: {}
    raise "no argument can be nil" unless harvest and name and node
    results = []
    harvest[:finds].select{|f| f[:from] == name}.each do |f|
      found_nodes = node.css f[:css]
      found_nodes.each do |found_node|
        found_nodes_hash[f[:as]] = found_node
        #Notice that the last one actually stays defined forever!
        results.push *(harvest_for harvest: harvest, name: f[:as], node: found_node, found_nodes_hash: found_nodes_hash)
        found_nodes_hash.each do |name, node|
          Scraperer.define_my_method name, node
        end
        results.push *scrape_for(harvest: harvest, name: f[:as])
      end
    end
    results
  end
  
  def self.scrape_for harvest: nil, name: nil
    results = []
    raise "no argument can be nil" unless harvest and name
    harvest[:scrapers].select{|s| s[:name].to_sym == name.to_sym}.each do |s|
      sc = Scraperer.new s
      results << sc.execute
    end
    results
  end
  
  class Scraperer
    def self.define_my_method name, node
      define_method name do
        node
      end
    end
    def initialize scraper
      @scaper = scraper
      @is_scraping = false
      @result = {
          sort: [],
          object: {}
        }
    end
    def execute
      @is_scraping = true
      begin
        self.instance_exec &@scaper[:block]
      rescue
        @result[:object] = nil
      end
      @is_scraping = false
      @result
    end

    def method_missing(name, *args, &block)
      if @is_scraping
        raise "scraperer: value not given for method #{name}" if args.length == 0
        value = args[0].to_s
        @result[:object][name.to_sym] = value
        (1..args.length - 1).each do |index|
          case args[index]
          when :mandatory
            raise "empty mandatory field #{name}" if value.empty?
          when :sort
            @result[:sort] << name.to_sym
          else
            raise "unknown parameter next to field name #{name}"
          end
        end
      else
        super 
      end
    end
  end
  
  class FindProcessor
    attr_reader :finds
    attr_reader :scrapers
    def initialize current_element_node: nil, block: block
      @current_element_node = (current_element_node || 'document')
      @finds = []
      @block = block
      @scrapers = []
    end
    
    def find css: nil, as: nil
      unless as
        as = css[/\w+/] if css
      end
      raise "You need to specify 'as' if it cannot be deducted from somewhere." unless as
      finds << {
          from: @current_element_node,
          css: css,
          as: as
        }
      if block_given?
        prev_element_node = @current_element_node
        @current_element_node = as
        self.instance_exec { yield }
        @current_element_node = prev_element_node
      end
    end
    
    def scrape name, &block
      raise "you have to define the name of the scrape" unless name
      @scrapers << {
        name: name,
        block: block
      }
    end
    
    def execute
      self.instance_exec &@block
    end
  end
  
  def self.do_filter scan, filter_for: :anything
    @@filters.each do |f|
      if filter_for == :anything or 
          f[:only_for].include? :always or
          f[:only_for].include? filter_for
        begin
          return f[:rule] == :allow if scan.instance_exec &f[:block]
          # above line will return false if rule is :deny (or anything else)
        rescue
        end
      end
    end
    false
  end
end