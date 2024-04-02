({ 
    doInit : function(component, event, helper) { 
        var vProductId = component.get("v.recordId");
        console.log(vProductId);
        helper.RefreshWrapper(component, event);        
    },

    handleCancel: function (component, event, helper) { 
 		// Close the action panel 

        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 

        dismissActionPanel.fire(); 

    } ,
    handleSendEmail: function (component, event, helper) { 
        var vEmail = component.get("v.inputEmail");
        var vProductId = component.get("v.recordId");
        console.log(vProductId);
        console.log(vEmail);
	 		
 		var action = component.get("c.sendEmailToUser");   // Call server class method
        // set Parameter
        action.setParams({
            "emailId": vEmail,
            "productId": vProductId
			            
        });       
        action.setCallback(this, function(data) {  //call back
            var state= data.getState();// check the result from server 
            //component.set("v.isLoading",false);
            if(state=="SUCCESS"){
                
            }
            else{
				var errors = data.getError();
                $A.log(errors);
                if(errors || errors[0].message){
                    console(errors[0].message);
                }
            }
        });        
        $A.enqueueAction(action);

        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 

        dismissActionPanel.fire(); 

    } 


})