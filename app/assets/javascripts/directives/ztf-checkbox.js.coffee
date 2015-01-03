@zt_module.directive 'ztfCheckbox', ->
  directive_object =
    restrict: 'E'
    transclude: true
    scope:
      ztField: '@'
    link: (scope, elem, attr) ->
      s while !(s = (s || scope).$parent).isZtfForm
      scope.form = s 
    controller: ($scope) ->
      $scope.revertLocal = ->
        $scope.form.getItem().copy[$scope.ztField] = $scope.form.getItem().data[$scope.ztField] unless $scope.fieldUpdating()
      $scope.fieldModified = ->
        $scope.form.updating and $scope.form.getItem().copy[$scope.ztField] != $scope.form.getItem().data[$scope.ztField]
      $scope.fieldUpdating = ->
        $scope.form.updating and $scope.form.updated_fields.indexOf($scope.ztField) > -1
      $scope.fieldError = ->
        $scope.form.error_fields.indexOf($scope.ztField) > -1 and $scope.fieldModified()
      $scope.fieldUpdated = ->
        $scope.form.updated_fields.indexOf($scope.ztField) > -1
      $scope.glyphTitle = ->
        if $scope.form and $scope.form.getItem() and $scope.fieldError()
          "Could not save changes. Click to revert."
    templateUrl: "ztf-checkbox.html"
