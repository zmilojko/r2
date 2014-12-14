# -*- coding: UTF-8 -*-

require 'harvester_parser'

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
  
  def self.loaded
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
  
  def self.find name
    res = loaded.select { |klass| klass.to_s == name }
    raise "No such harvester #{name}" unless res.count == 1
    res[0]
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
  
  def self.filter_url url, filter_for: :anything
    do_filter url, filter_for: filter_for
  end
  
  def self.perform_harvest name: nil
    raise "you should define site name before trying harvesting." unless @@site_name
    name ||= @@site_name
    current_harvest = @@crops[@@crops.index{|x| x[:name] == name}]
    raise "nothing to harvest. Define a harvest before performing it." unless current_harvest
    results_count = 0
    
    site = Site.find_by name: @@site_name
    sort = nil # sort is remembered, but is not currently used
               # it will be used later, when these definitions become
               # part of the Site object. Sort will be used when querying
               # data, not when storing it. Also, we will need to be indexing
               # some data somehow.
    
    site.scans.each do |scan|
      if do_filter scan, filter_for: :harvesting
        new_results = harvest_for harvest: current_harvest, name: 'document', node: scan.html

        new_results.select! { |r| r[:object] }
        new_results.map! do |r|
          sort = r[:sort]
          r[:object]
        end
        site.crops.create! new_results
        results_count += new_results.count
      end
    end
    results_count
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
    
    return true if @@site_name.blank?
    
    if scan.class == String
      scan = Site.find_by(name: @@site_name).scans.new do |s|
        s.last_visited = nil
        s.url = scan
      end
    end
    
    @@filters.each do |f|
      if filter_for == :anything or 
          f[:only_for].include? :always or
          f[:only_for].include? filter_for
        begin
          return f[:rule] == :allow if scan.instance_exec &f[:block]
        rescue
        end
      end
    end
    false
  end
end