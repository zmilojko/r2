@r2_module.controller 'SiteController', [
  '$scope', '$routeParams', '$location', '$window', 'siteService', 
  ($scope, $routeParams, $location, $window, siteService) ->
    $scope.new_seed = {}
    $scope.site_name = $routeParams.siteName;
    $scope.tab = 'seeds'
    $scope.site = ->
      return null unless $scope.sites
      my_site = site for site in $scope.sites when site.name == $scope.site_name
      console.log "it is null now" unless my_site
      my_site
    siteService.get_sites()
    .then (sites)->
      $scope.sites = sites
      unless $scope.site()
        console.log "Unknown site #{$scope.site_name}"
        $location.replace()
        $location.url("/404")
      else
        $scope.new_seed.site_name = $scope.site().site_name
        siteService.getSeedsAndScans($scope.site())
        .then (seeds_and_scans) ->
          $scope.seeds_and_scans = seeds_and_scans
    $scope.changeMode = (new_mode) ->
      siteService.changeMode($scope.site(), new_mode)
    $scope.save = ->
      siteService.saveSite($scope.site())
      $scope.form.$setPristine()
    $scope.cancel = ->
      $location.url("sites")
    $scope.deleteSite = ->
      siteService.deleteSite($scope.site())
      .then ->
        $location.url("sites")
    $scope.removeSeed = (seed) ->
      siteService.removeSeed(seed)
    $scope.addNewSeed = ->
      siteService.addSeed($scope.new_seed)
      .then ->
        $scope.new_seed.url = ""
]