@r2_module.controller 'SitesController', [
  '$scope', '$timeout', '$location', 'siteService', 
  ($scope, $timeout, $location, siteService) ->
    $scope.sites = []
    siteService.get_sites().then (sites)->
      $scope.sites = sites
      siteService.getSeedsAndScans(null)
    $scope.changeMode = (site, new_mode) ->
      siteService.changeMode(site, new_mode)
    $scope.newSiteButtonClicked = ->
      name = $scope.new_site_name
      siteService.createSite({name: name})
      .then ->
        $location.url("/sites/#{name}")
]