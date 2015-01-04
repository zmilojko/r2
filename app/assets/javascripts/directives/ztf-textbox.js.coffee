@zt_module.directive 'ztfTextbox', ->
  ret =
    restrict: 'E'
    transclude: false
    scope:
      ztField: '@'
      ztLabel: '@'
    link: (scope, elem, attr) ->
      s while !(s = (s || scope).$parent).hasOwnProperty('isZtfForm')
      scope.form = s
    controller: ($scope) ->
      $scope.index = ->
        if isDefined($scope.$parent.$parent.$index) then $scope.$parent.$parent.$index else null
      $scope.itemCopy = ->
        $scope.form.itemCopy($scope.ztField, $scope.index())
      $scope.revertLocal = ->
        $scope.form.revertField($scope.ztField, $scope.index())
      $scope.fieldModified = ->
        $scope.form.fieldModified($scope.ztField, $scope.index())
      $scope.fieldUpdating = ->
        $scope.form.fieldUpdating($scope.ztField, $scope.index())
      $scope.fieldError = ->
        $scope.form.fieldError($scope.ztField, $scope.index())
      $scope.fieldUpdated = ->
        $scope.form.fieldUpdated($scope.ztField, $scope.index())
      $scope.glyphTitle = ->
        if $scope.form and $scope.itemCopy() and $scope.fieldError()
          "Could not save changes. Click to revert."
    templateUrl: "ztf-textbox.html"
 