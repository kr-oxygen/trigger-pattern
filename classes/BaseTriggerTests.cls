@isTest 
private class BaseTriggerTests {
	@isTest
	private static void testShouldEnableTriggerForType() {
		BaseTriggerHandler sut = new BaseTriggerHandler();

		sut.enable(Account.sObjectType);

		System.assert(TriggerFactory.disabledTriggers.containsKey(Account.sobjectType), 'The type should be registred in the TriggerFactory');

		Boolean isEnabled = TriggerFactory.disabledTriggers.get(Account.sobjectType);

		System.assert(isEnabled, 'The type should be Enabled');
	}

	@isTest
	private static void testShouldDisabledTriggerForType() {
		BaseTriggerHandler sut = new BaseTriggerHandler();

		sut.disable(Account.sObjectType);

		System.assert(TriggerFactory.disabledTriggers.containsKey(Account.sobjectType), 'The type should be registred in the TriggerFactory');

		Boolean isEnabled = TriggerFactory.disabledTriggers.get(Account.sobjectType);

		System.assert(!isEnabled, 'The type should be Disabled');
	}

	@isTest
	private static void testShouldGetObjectIfItIsInContainer() {
		BaseTriggerHandler sut = new BaseTriggerHandler();

		Account a = new Account(Name = 'Test');

		insert a;

		sut.toUpdate.put(a.Id, a);
		Account acc = (Account)sut.getUpdate(a.Id, Account.sObjectType);

		System.assert(acc != null, 'The object must not be null.');
		System.assertEquals(a, acc, 'The object must be same');
	}

	@isTest
	private static void testShouldGetObjectIfItIsNotInContainer() {
		BaseTriggerHandler sut = new BaseTriggerHandler();

		Account a = new Account(Name = 'Test');

		insert a;

		Account acc = (Account)sut.getUpdate(a.Id, Account.sObjectType);

		System.assert(acc != null, 'The object must not be null.');
		System.assertEquals(a.Id, acc.Id, 'The object must have same id');
	}

	@isTest
	private static void testJustIcreaseCoverageForVirtualMethods() {
		BaseTriggerHandler sut = new BaseTriggerHandler();
		sut.bulkBefore();
		sut.bulkAfter();
		sut.beforeInsert(null);
		sut.beforeUpdate(null, null);
		sut.beforeDelete(null);
		sut.afterInsert(null);
		sut.afterUpdate(null, null);
		sut.afterDelete(null);
		sut.afterUndelete(null);
		sut.andFinally();
	}
}