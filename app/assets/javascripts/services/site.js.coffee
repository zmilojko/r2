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
          service.sites[i] = server_response.data for i in [0..service.sites.length - 1] when service.sites[i].sid = site.sid
      keepPinging: ->
        service.pinging = true
        $timeout ->
          service.doGetSites()
          .then (sites) ->
            service.keepPinging()
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
    service.constructor()
]
