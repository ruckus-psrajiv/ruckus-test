trigger assetTrigger on Asset (before insert, after insert, before update, after update) {
    Set<String> sapSoIds = new Set<String>();
    Set<String> sapSoLiIds = new Set<String>();
    Set<Id> SoLiIds = new Set<Id>();
    List<Asset> newassets = new List<Asset>();
    if (trigger.isInsert){
    	if (trigger.isBefore && AssetClass.beforeonce){
    		for (Asset ast : trigger.new){
            	if (ast.SAPSalesOrderId__c != null){
                	sapSoIds.add(ast.SAPSalesOrderId__c);
                	newassets.add(ast);
            	}
        	} 
        	if (sapSoIds.size() > 0){  
        		AssetClass.SetAssetFields(sapSoIds, newassets);
        		AssetClass.beforeonce = false;
        	}
    	}
    	if (trigger.isAfter && AssetClass.afteronce){
            // After Insert value of Trigger.new will be passed to helper class for APPTUS CPQ related logic calculation - [APTTUS-08]
            AssetTriggerHelperClass.updateListPriceOnAssetInsert(Trigger.new);
            AssetTriggerHelperClass.updateUnitPriceOnAssetInsertAndUpdate(Trigger.new);
    		List<Asset> createEntitlementList = new List<Asset>();
    		for (Asset ast : trigger.new){
    			if (ast.Sales_Order_Item__c != null){
    				SoLiIds.add(ast.Sales_Order_Item__c);
    				newassets.add(ast);
    			}
    			if(ast.Excluded_From_Warranty__c == null || !ast.Excluded_From_Warranty__c) {
    				createEntitlementList.add(ast);
    			}
    		}
    		AssetClass.CreateServiceContract(trigger.new);
    		if (SoLiIds.size() > 0){
    			AssetClass.updateShipQty(newassets, SoLiIds);
    		}
			//cweiss@forefrontcorp.com  20130329 
			//cweiss@forefrontcorp.com 20130524 Updated. Do not create the warranties when the assets are created only create them via the SWU
			//AssetClass.CreateWarranties(trigger.new);
			//AssetClass.CreateEntitlement(trigger.new);
			// SD@Ruckus - Uncommented // Commented for time being to fix the Asset Creation error first
			//AssetClass.CreateEntitlement(JSON.serialize(trigger.new));
			if(createEntitlementList.size() > 0) {
				AssetClass.CreateEntitlement(JSON.serialize(createEntitlementList));
			}
        	//end 20130329 change
			AssetClass.afteronce = false;
    	}
    } else { //trigger.isUpdate
    	if (trigger.isBefore){
    		for (Asset ast : trigger.new){
    			Asset oldAst = trigger.oldMap.get(ast.Id);
    			if (ast.SAPSalesOrderId__c != null && (ast.SAPSalesOrderId__c != oldAst.SAPSalesOrderId__c || ast.SAPLineNo__c != oldAst.SAPLineNo__c)){
                	sapSoIds.add(ast.SAPSalesOrderId__c);
                	newassets.add(ast);
            	}
    		}
    		if (sapSoIds.size() > 0){  
        		AssetClass.SetAssetFields(sapSoIds, newassets);
        		AssetClass.beforeonce = false;
        	}
    	} else {//trigger.isAfter
    		List<Asset> updassets = new List<Asset>();
            // After Update value of Trigger.new will be passed (After validation) to helper class for APPTUS CPQ related logic calculation - [APTTUS-08]
            List<Asset> lAssetsFromTriggetToClass = new List<Asset> (); // APTTUS - CPQ [APTTUS-08]
    		for (Asset ast : trigger.new){
    			Asset oldAst = trigger.oldMap.get(ast.Id);
                // After Update condition check block added for APPTUS CPQ related requirements - [APTTUS-08]
                if(ast.Sales_Order_Item__c != oldAst.Sales_Order_Item__c){
                    lAssetsFromTriggetToClass.add(ast);
                }
    			if (ast.Sales_Order_Item__c != null && ast.Sales_Order_Item__c != oldAst.Sales_Order_Item__c){
    				SoLiIds.add(ast.Sales_Order_Item__c);
    				updassets.add(ast);
    			}
    		}
            // After Update (condition check) the values of Trigger.new will be passed to helper class for Further processing for APPTUS CPQ related requirements - [APTTUS-08] 
            AssetTriggerHelperClass.updateUnitPriceOnAssetInsertAndUpdate(lAssetsFromTriggetToClass); 
    		if (SoLiIds.size() > 0 ) {AssetClass.updateShipQty(updassets, SoLiIds);}
    	}
    }        	
}