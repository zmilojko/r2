s = Site.new name: "kauppa.ouluvet.fi",
             # default_ssl: false
             # mode: :off,
             # status: :off,
             start_time: 23,
             end_time:6,
             encoding: "iso-8859-15"

s.save!

s.scans.create! url: "/", seed: true