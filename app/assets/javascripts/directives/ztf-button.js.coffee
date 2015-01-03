@zt_module.directive 'ztfButton', ->
  ret =
    restrict: 'AE'      # also possible class C
    transclude: true    # set to false if ignoring content
    scope:
      cmd: '&ztfCommit'    # isolate scope of a function, passed as a value 
                              # of the attribute with the name of the directive
      disabled: '='     # isolate scope of a model (both ways), passed with an 
                        # attribute disabled="XXX", where XXX is a variable of 
                        # the scope
      glyph: '@'        # isolate scope of a variable (in only), passed with 
                        # an attribute disabled="123"
    link: (scope, elem, attrs) ->
      s while !(s = (s || scope).$parent).isZtfForm
      scope.form = s 
      scope.action = 'commit' if isDefined(attrs.commit)
      scope.action = 'cancel' if isDefined(attrs.cancel)
      scope.action = 'edit' if isDefined(attrs.edit)
      scope.action = attrs.action if isDefined(attrs.action)
      scope.title_given = elem.find('span')[0].children.length;
    templateUrl: "ztf-button.html"