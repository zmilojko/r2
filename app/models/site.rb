class Site
  include Mongoid::Document
  field :name, type: String
  field :default_ssl, type: Mongoid::Boolean, default: false
  field :mode, type: String, default: :off
  field :status, type: String, default: :off
  field :start_time, type: Integer, default: 0
  field :end_time, type: Integer, default: 0
  field :use_ssl, type: Mongoid::Boolean, default: false
  field :encoding, type: String, default: ""
  field :ticket_no, type: String
  embeds_many :rules
  has_many :scans
  
  # modes: :off, :on (runs by schedule), :forced
  def mode_sym
    (mode || :off).to_sym
  end
  def mode_was_sym
    (mode_was || :off).to_sym
  end
  # statuses: :off (as in completed or stopped by timer or mode set to off), :on, :asleep, :interrupted (as in a problem)
  def status_sym
    (status || :off).to_sym
  end
  def scanning_schedule
    if start_time == 0 and end_time == 0
      "always on"
    else
      "#{start_time} -> #{end_time}"
    end
  end
  
  def scanning_status
    if (total_scans = scans.count) == 0
      "not seeded"
    elsif (nil_scans = scans.where(last_visited: nil).count) > 0
      "#{total_scans - nil_scans} / #{total_scans}"
    else
      "first round done"
    end
  end
  
  def should_sleep
    if mode_sym == :forced
      false
    elsif start_time == 0 and end_time == 0
      "always on"
    elsif start_time <= end_time
      not Time.now.hour.between? start_time, end_time
    else
      Time.now.hour.between? end_time + 1, start_time - 1
    end
  end
  
  before_validation do
    if mode_changed? and mode_was_sym == :off and mode_sym == :on
      puts "Decided to start the task on #{name}"
      self.ticket_no = SecureRandom.hex
      puts "My ticket no is #{ticket_no}"
      @should_start_scanning = true
    end
    true
  end
  
  after_save do
    if @should_start_scanning
      puts "Starting scanning task for #{name}"
      Scanner.perform_async name, ticket_no
    end
    @should_start_scanning = false
    true
  end
  
  def as_json(**args)
    super(args).merge(scanning_schedule: scanning_schedule, scanning_status: scanning_status, sid: id.to_s)
  end
  
  def update(params)
    self.name = params[:name] unless params[:name].nil?
    self.use_ssl = params[:use_ssl]  unless params[:use_ssl].nil?
    self.mode = params[:mode] unless params[:mode].nil?
    self.start_time = params[:start_time] unless params[:start_time].nil?
    self.end_time = params[:end_time] unless params[:end_time].nil?
    self.encoding = params[:encoding] unless params[:encoding].nil?
    #remove deleted rules
    unless params[:rules].nil?
      self.rules.delete_all 
      params[:rules].each do |rule_params|
        r = self.rules.find_or_initialize_by regex: rule_params[:regex]
        r.regex = rule_params[:regex]
        r.positive = rule_params[:positive]
        r.order = rule_params[:order]
      end
    end
    save
  end
end
