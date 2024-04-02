({
    init: function (component, event, helper) {
        window.addEventListener('DOMContentLoaded', function () {
           // helper.adjustModalHeight(component);
        });

        window.addEventListener('resize', function () {
         //   helper.adjustModalHeight(component);
        });
    },
	closeQA : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})