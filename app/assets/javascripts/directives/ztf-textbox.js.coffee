@zt_module.directive 'ztfTextbox', ['$timeout', ($timeout) ->
  ret =
    restrict: 'E'
    transclude: false
    scope:
      ztField: '@'
    link: (scope, elem, attr) ->
      s while !(s = (s || scope).$parent).isZtfForm
      scope.form = s 
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
    controller: ($scope) ->
      $scope.startEditing = ->
        $scope.status = 3 if $scope.status == 0
      $scope.revertLocal = ->
        $scope.field_value = $scope.getItem().copy[$scope.ztField]
        $scope.status = 0
    templateUrl: "ztf-textbox.html"
  ]
