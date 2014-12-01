def reset_case
  s = Site.first
  s.mode = :off
  s.save!

  Scan.delete_all
  Site.first.scans.create url: "/", last_visited: nil

  s.mode = :on
  s.save!
end

def stop_case
  s = Site.first
  s.mode = :off
  s.save!
end  

def clean_case
  Scan.delete_all
  Site.first.scans.create url: "/", last_visited: nil
end