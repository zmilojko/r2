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
        @sites = null
        service
      get_sites: ->
        if @sites
          $q.when @sites
        else
          $http.get('./sites.json').then (server_response) ->
            service.keepPinging()
            service.sites = server_response.data
      changeMode: (site, new_mode) ->
        $http.patch("./sites/#{site.id.$oid}.json", {mode: new_mode}).then (server_response) ->
          service.sites[i] = server_response.data for i in [0..service.sites.length - 1] when service.sites[i].id.$oid = site.id.$oid
      keepPinging: ->
        $timeout ->
          $http.get('./sites.json').then (server_response) ->
            for i in [(service.sites.length - 1) .. 0]
              is_there = false
              for j in [(server_response.data.length - 1) .. 0]
                if service.sites[i].id.$oid == server_response.data[j].id.$oid
                  service.sites[i] = server_response.data[j]
                  is_there = true
                  server_response.data.splice(j,1)
                  break
              unless is_there
                service.sites.splice(i,1)
            service.keepPinging()
        , 2000
    service.constructor()
]
