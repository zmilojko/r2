###
Site = $resource('/sites/:siteId', {siteId:'@id'}, 
  {
    charge: {method:'POST', params:{charge:true}}
  })
###
@r2_module.service 'siteService', [
  '$http', '$q', '$timeout', 'localStorageService',
  ($http, $q, $timeout, localStorageService) -> 
    service =
      constructor: ->
        @sites = []
        @current_site = null
        @current_site_scans = 
          seeds: [],
          latest_scans: [],
          next_scans: []
        @pinging = false
        service
      get_sites: ->
        if @pinging
          $q.when @sites
        else
          service.doGetSites()
          .then (sites) ->
            service.keepPinging() unless service.pinging
            service.sites
      getSeedsAndScans: (current_site) ->
        if current_site == service.current_site
          $q.when service.current_site_scans
        else
          @current_site_scans = 
            seeds: [],
            latest_scans: [],
            next_scans: []
          if current_site
            service.doGetScans(current_site)
            .then (scans) ->
              service.current_site = current_site
              service.keepPingingScans(current_site)
              scans
          else
            service.current_site = current_site
      doGetScans: (current_site) ->
        $http.get("./sites/#{current_site.sid}/scans/report.json?limit=10")
        .then (server_response) ->
          service.current_site_scans.seeds.length = 0
          Array.prototype.push.apply(service.current_site_scans.seeds, server_response.data.seeds)
          service.current_site_scans.latest_scans.length = 0
          Array.prototype.push.apply(service.current_site_scans.latest_scans, server_response.data.latest_scans)
          service.current_site_scans.next_scans.length = 0
          Array.prototype.push.apply(service.current_site_scans.next_scans, server_response.data.next_scans)
          service.current_site_scans
      keepPingingScans: (current_site) ->
        $timeout ->
          if service.current_site == current_site && current_site
            service.doGetScans(current_site)
            .then (scans) ->
              unless window.stopScanning
                service.keepPingingScans(current_site)
        , 2000 if service.current_site == current_site && current_site
      doGetSites: ->
        defer = $q.defer()
        $http.get('./sites.json')
        .then (server_response) ->
          service.sites.length = 0
          Array.prototype.push.apply(service.sites, server_response.data)
          defer.resolve(service.sites)
        defer.promise
      changeMode: (site, new_mode) ->
        $http.patch("./sites/#{site.sid}.json", {mode: new_mode}).then (server_response) ->
          service.sites[i] = server_response.data.site for i in [0..service.sites.length - 1] when service.sites[i].sid == site.sid
      keepPinging: ->
        service.pinging = true
        $timeout ->
          service.doGetSites()
          .then (sites) ->
            service.keepPinging() unless window.stopScanning
        , 2000
      createSite: (site) ->
        defer = $q.defer()
        $http.post('./sites.json', site)
        .then (server_response) ->
          service.doGetSites()
          .then (sites)->
            defer.resolve(server_response.data)
        defer.promise
      saveSite: (site) ->
        defer = $q.defer()
        $http.put("./sites/#{site.sid}.json", site)
        .then (server_response) ->
          service.doGetSites().then (sites) ->
            defer.resolve(server_response.data)
        defer.promise
      deleteSite: (site) ->
        defer = $q.defer()
        $http.delete("./sites/#{site.sid}.json")
        .then (server_response) ->
          service.doGetSites().then (sites) ->
            defer.resolve(server_response.data)
        defer.promise
      removeSeed: (seed) ->
        $http.delete("./sites/#{service.current_site.sid}/scans/#{seed._id.$oid}.json")
      addSeed: (new_seed) ->
        $http.post("./sites/#{service.current_site.sid}/scans/newseed.json", new_seed)
    service.constructor()
]
