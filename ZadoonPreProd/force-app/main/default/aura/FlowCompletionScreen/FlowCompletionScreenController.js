({
    doInit: function(component, event, helper) {
        console.log('close screen flow'); 
        setTimeout(() => {
            var navigate = component.get("v.navigateFlow");
            navigate("FINISH");
        }, 3000);
            console.log('screen flow');   
        }
})