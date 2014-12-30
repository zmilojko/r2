@zt_module.directive 'ztTextbox', ->
  directive_object =
    restrict: 'E'
    transclude: true
    scope:
      ztItem: '=?'
      ztField: '@'
      ztUpdateSuccess: '&?'
    link: (scope, elem, attr) ->
      unless typeof scope.ztItem == "undefined"
        scope.$watch (scope) ->
          scope.ztItem
        , ->
          scope.revertLocal() if scope.ztItem
      else
        scope.$parent.$watch (parent_scope) ->
          parent_scope.item
        , ->
          scope.revertLocal() if scope.$parent.item
    controller: ['$timeout', '$scope', ($timeout, $scope) ->
      $scope.status = 0
      $scope.getItem = ->
        $scope.ztItem or $scope.$parent.item
      $scope.startEditing = ->
        $scope.status = 3 if $scope.status == 0
      $scope.revertLocal = ->
        $scope.field_value = $scope.getItem().copy[$scope.ztField]
        $scope.status = 0
      $scope.cancelEditing = ->
        $scope.getItem().revert()
        $scope.revertLocal()
      $scope.completeEditing = ->
        $scope.status = 2
        ct1 = $scope.ct1 = ($scope.ct1 + 1 || 0)
        $scope.getItem().copy[$scope.ztField] = $scope.field_value
        $scope.getItem().save()
        .then ->
          if ct1 == $scope.ct1 and $scope.status == 2
            $scope.status = 1
            ct2 = $scope.ct2 = ($scope.ct2 + 1 || 0)
            $timeout ->
              if ct2 == $scope.ct2 and $scope.status == 1
                if $scope.ztUpdateSuccess?
                  $scope.ztUpdateSuccess()
                $scope.status = 0
            ,2000
        .catch ->
          $scope.status = 4
    
    ]
    templateUrl: "zt-textbox.html" 

