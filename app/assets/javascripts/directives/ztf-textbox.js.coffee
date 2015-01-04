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
      scope.index = if isDefined(scope.$parent.$parent.$index) then scope.$parent.$parent.$index else null
    controller: ($scope) ->
      $scope.itemCopy = ->
        $scope.form.itemCopy($scope.ztField, $scope.index)
      #$scope.item = ->
      #  $scope.form.getItem($scope.index)
      $scope.revertLocal = ->
        $scope.form.revertField($scope.ztField, $scope.index)
        #$scope.item().copy[$scope.ztField] = $scope.item().data[$scope.ztField] unless $scope.fieldUpdating()
      $scope.fieldModified = ->
        $scope.form.fieldModified($scope.ztField, $scope.index)
        #$scope.item() and $scope.item().copy[$scope.ztField] != $scope.item().data[$scope.ztField]
      $scope.fieldUpdating = ->
        $scope.form.fieldUpdating($scope.ztField, $scope.index)
        #$scope.form.updating and $scope.form.updated_fields.indexOf($scope.ztField) > -1
      $scope.fieldError = ->
        $scope.form.fieldError($scope.ztField, $scope.index)
        #$scope.form.error_fields.indexOf($scope.ztField) > -1 and $scope.fieldModified()
      $scope.fieldUpdated = ->
        $scope.form.fieldUpdated($scope.ztField, $scope.index)
        #$scope.form.updated_fields.indexOf($scope.ztField) > -1
      $scope.glyphTitle = ->
        if $scope.form and $scope.itemCopy() and $scope.fieldError()
          "Could not save changes. Click to revert."
    templateUrl: "ztf-textbox.html"
 