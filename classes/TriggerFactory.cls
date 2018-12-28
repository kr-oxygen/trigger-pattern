/**
 * Class TriggerFactory
 *
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 */
public class TriggerFactory { 
	//--------------------------------------------------------------------------
	// Properties

	// keep track of which triggers was disabled from other triggers
	public static Map<SObjectType, Boolean> disabledTriggers = new Map<SObjectType, Boolean>();

	//--------------------------------------------------------------------------
	// Methods
  
	/**
	* handle the current trigger execution with the handler for the specified
	* object; also detect and notify the handler if this is a reentrant call.
	* @param o the object type; the handler must be named
	* <code>&lt;o&gt;Handler</code> and implement ITriggerHandler
	*/
	public static void handle(SObjectType o) {
		// determine if this trigger is enabled in custom settings
		if (false != disabledTriggers.get(o)) {// && SF.isTriggerActive(o)) {
			final String triggerDesc = (Trigger.isBefore? 'Before' : 'After') +
			(Trigger.isInsert? 'Insert' : Trigger.isUpdate? 'Update' : Trigger.isDelete? 'Delete' : 'Undelete');
			//SF.debugBegin('Trigger: ' + triggerDesc + ' -> ' + o);

			// determine if this is the first call to this trigger in this execution context
			ITriggerHandler handler = getHandler(o);
	  
			// Execute the handler to fulfil the trigger
			if (null != handler) {
				execute(handler);
			}
		}
	}

	//--------------------------------------------------------------------------
	// Helpers
	/**
	* call various methods on the supplied handler based on the current trigger type.
	* @param handler the handler; may not be null
	*/
	@TestVisible private static void execute(ITriggerHandler handler) {
		try {
			if (Trigger.isBefore) {
				handler.BulkBefore();

				if (Trigger.isDelete) {
					for (SObject so : Trigger.old) {
						handler.beforeDelete(so);
					}
				} else if (Trigger.isInsert) {
					for (SObject so : Trigger.new) {
						handler.beforeInsert(so);
					}
				} else if (Trigger.isUpdate) {
					for (SObject so : Trigger.old) {
						handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
					}
				}
			} else {
				handler.bulkAfter();

				if (Trigger.isDelete) {
					for (SObject so : Trigger.old) {
						handler.afterDelete(so);
					}
				} else if (Trigger.isInsert) {
					for (SObject so : Trigger.new) {
						handler.afterInsert(so);
					}
				} else if (Trigger.isUpdate) {
					for (SObject so : Trigger.old) {
						handler.afterUpdate(so, Trigger.newMap.get(so.Id));
					}
				} else if (Trigger.isUndelete) {
					for (SObject so : Trigger.new) {
						handler.afterUndelete(so);
					}
				}
			}
	  
			handler.andFinally();
			//BaseTest.throwIfTesting(new NullPointerException());
		} catch (Exception ex) {
			//SF.debugException(ex);
			throw ex;
		} finally {
			//SF.debugEnd();
		}
	}

	/**
	* get the handler for the specified SObject
	* @param o the object type
	*/
	private static ITriggerHandler getHandler(SObjectType o) {
		try {
			//BaseTest.throwIfTesting(new NullPointerException());
			return (ITriggerHandler)Type.forName(String.valueOf(o).removeEnd('__c').
			replace('__', '_') + 'Handler').newInstance();
		} catch (NullPointerException ex) {
			return null;
		}
	}
}