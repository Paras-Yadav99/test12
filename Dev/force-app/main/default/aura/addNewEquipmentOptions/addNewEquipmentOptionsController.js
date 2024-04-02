({
    doInit : function(component, event, helper) {
       helper.doInit(component, event, helper);
        
    },
    handleSuccess : function(component, event, helper) {
        helper.handleSuccess(component, event, helper);
    },
    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
	}
})