({
	doInit : function(component, event, helper) {
        

        // Example: Navigate to a URL with a parameter
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/sendEmailUnitPage?id="+component.get('v.recordId')
        });
        urlEvent.fire();
    	
	}
})