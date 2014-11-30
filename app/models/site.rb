class Site
  include Mongoid::Document
  field :name, type: String
  field :default_ssl, type: Mongoid::Boolean, default: false
  field :mode, type: String, default: :off
  field :status, type: String, default: :off
  field :start_time, type: Integer, default: 0
  field :end_time, type: Integer, default: 0
  embeds_many :rules
  has_many :scans
  
  # modes: :off, :on (runs by schedule), :forced
  def mode_sym
    mode.to_sym
  end
  # modes: :off, :on, :asleep
  def status_sym
    mode.to_sym
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
end
