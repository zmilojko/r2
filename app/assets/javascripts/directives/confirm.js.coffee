@r2_module.directive 'ngConfirmClick', ->
  directive_object =
    link: (scope, element, attr) ->
      msg = attr.ngConfirmClick || "Are you sure?";
      clickAction = attr.confirmedClick;
      element.bind 'click', (event) ->
        if window.confirm(msg)
          scope.$eval clickAction
