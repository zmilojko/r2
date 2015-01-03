@zt_module.directive 'ztAutoCheckbox', ['$timeout', ($timeout) ->
  directive_object =
    restrict: 'E'
    transclude: true
    scope:
      ztItem: '=?'
      ztField: '@'
    controller: ($scope) ->
      $scope.status = 0
      $scope.getItem = ->
        $scope.ztItem or $scope.$parent.item
      $scope.doPerformUpdate = ->
        $scope.status = 1
        ct1 = $scope.ct1 = ($scope.ct1 + 1 || 0)
        $scope.getItem().save()
        .then ->
          if ct1 == $scope.ct1 and $scope.status = 1
            $scope.status = 2
            ct2 = $scope.ct2 = ($scope.ct2 + 1 || 0)
            $timeout ->
              if ct2 == $scope.ct2 and $scope.status == 2
                $scope.status = 0
            ,2000
        .catch ->
          $scope.getItem().revert()
          $scope.status = 3
    templateUrl: "zt-auto-checkbox.html" 
]
