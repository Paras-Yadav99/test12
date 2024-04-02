({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get("c.getRequiredValues");
        action.setParams({ recordId : component.get('v.recordId') });
        action.setCallback(this, function(response){
            var state = response.getState();
            var fields;
            if (state === "SUCCESS") {
                var value = response.getReturnValue();
                component.set("v.fields",value.fieldSet);
                component.set("v.fieldsLoaded", true);
                component.set("v.category", value.Category[0]);
            }
            });
	    $A.enqueueAction(action);
        
    },
    handleSuccess : function(component, event, helper) {
        var action = component.get("c.updateParentId");
        var respo = JSON.parse(JSON.stringify(event.getParams().response));
        action.setParams({ recordId : respo.id, parentId : component.get('v.recordId') });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": respo.id,
                  "slideDevName": "related"
                });
                navEvt.fire();
                this.showToast_notifLib(component,"success","Record Created", "Record ID: " + respo.id );
            }});
        $A.enqueueAction(action);
    },
    showToast_notifLib: function(component, variant, title, message){
        component.find('notifLib').showToast({
            "variant": variant,
            "title": title,
            "message": message
         });
    }
})