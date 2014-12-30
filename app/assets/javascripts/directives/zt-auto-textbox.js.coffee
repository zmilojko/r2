@zt_module.directive 'ztAutoTextbox', ->
  directive_object =
    restrict: 'E'
    transclude: false
    scope:
      ztItem: '=?'
      ztField: '@'
      ztUpdateSuccess: '&?'
    controller: ['$timeout', '$scope', ($timeout, $scope) ->
      $scope.status = 0
      $scope.getItem = ->
        $scope.acItem or $scope.$parent.item
      $scope.inputTextChange = ->
        $scope.status = 1
        ct1 = $scope.ct1 = ($scope.ct1 + 1 || 0)
        $timeout -> 
          if ct1 == $scope.ct1
            $scope.completeEditing()
        ,1000
      $scope.completeEditing = ->
        $scope.status = 2
        ct2 = $scope.ct2 = ($scope.ct2 + 1 || 0)
        $scope.getItem().save()
        .then ->
          if ct2 == $scope.ct2 and $scope.status == 2
            $scope.status = 3
            ct3 = $scope.ct3 = ($scope.ct3 + 1 || 0)
            $timeout ->
              if ct3 == $scope.ct3 and $scope.status == 3
                $scope.status = 0
                if $scope.ztUpdateSuccess?
                  $scope.ztUpdateSuccess()
            ,2000
        .catch ->
          $scope.status = 4
    ]
    templateUrl: "zt-auto-textbox.html" 

