class Site
  include Mongoid::Document
  field :name, type: String
  field :default_ssl, type: Mongoid::Boolean, default: false
  field :mode, type: String, default: :off
  field :status, type: String, default: :off
  field :start_time, type: Integer, default: 0
  field :end_time, type: Integer, default: 0
  
  # modes: :off, :on (runs by schedule), :forced
  def mode_sym
    mode.to_sym
  end
  # modes: :off, :on, :asleep
  def status_sym
    mode.to_sym
  end
end
