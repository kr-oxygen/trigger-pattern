/**
 * Base implementation of ITrigger. Derive your handler from this class, then
 * override methods as needed.
 */
public with sharing virtual class BaseTriggerHandler {
	//--------------------------------------------------------------------------
	// Properties
	public SObject[] toInsert = new SObject[]{};
	public Map<Id,SObject> toUpdate = new Map<Id,SObject>();
	public Map<Id,SObject> toDelete = new Map<Id,SObject>();
  
	//--------------------------------------------------------------------------
	// Methods
	public virtual void bulkBefore() {  }
	public virtual void bulkAfter() {  }
	public virtual void beforeInsert(SObject so) {  }
	public virtual void beforeUpdate(SObject oldSo, SObject so) {  }
	public virtual void beforeDelete(SObject so) {  }
	public virtual void afterInsert(SObject so) {  }
	public virtual void afterUpdate(SObject oldSo, SObject so) {  }
	public virtual void afterDelete(SObject so) {  }
	public virtual void afterUndelete(SObject so) {  }
  
	/** insert, update, and delete the processed records */
	public virtual void andFinally() {
		insert toInsert;
		update toUpdate.values();
		delete toDelete.values();
	}
  
	/**
	* get the object with Id 'i' from the 'toUpdate' list. This is needed when
	* several functions modify the same object within a handler. The second function
	* calls this so as to not override the changes the first function made.
	*/
	public SObject getUpdate(Id i, SObjectType type) {
		return getObject(i, toUpdate, type);
	}
  
	public void enable(SObjectType type) {
		TriggerFactory.disabledTriggers.put(type, true);
	}

	public void disable(SObjectType type) {
		TriggerFactory.disabledTriggers.put(type, false);
	}

	//--------------------------------------------------------------------------
	// Helpers
	private SObject getObject(Id i, Map<Id,SObject> objects, SObjectType type) {
		if (!objects.containsKey(i)) {
			objects.put(i, type.newSObject(i));
		}
	
		return objects.get(i);
	}
}