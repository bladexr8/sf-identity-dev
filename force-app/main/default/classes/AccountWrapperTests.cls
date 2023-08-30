@IsTest
private class AccountWrapperTests {
  @TestSetup
  static void loadTestData() {
    // GIVEN
    Account acct = new Account(Name = 'ACME');
    insert acct;
    Account acct2 = new Account(Name = 'ACME2');
    insert acct2;
    List<Opportunity> opps = TestFactory.generateOppsForAccount(acct.id, 1000.00, 5);
    insert opps;
    List<Opportunity> opps2 = TestFactory.generateOppsForAccount(acct2.id, 200000.00, 5);
    insert opps2;
  }
  @IsTest
  static void testPositiveRoundedAveragePrice() {
    // WHEN
    Account acct = [SELECT Id FROM Account WHERE Name = 'ACME'];
    AccountWrapper acctWrapper = new AccountWrapper(acct);
    // THEN
    Test.startTest();
    Assert.areEqual(
      acctWrapper.getRoundedAvgPriceOfOpps(),
      1000.00,
      'Expected to get 1000.00');
    Test.stopTest();
  }
  @IsTest
  static void isHighPriority() {
    // WHEN
    Account acct = [SELECT Id FROM Account WHERE Name = 'ACME2'];
    AccountWrapper acctWrapper = new AccountWrapper(acct);
    // THEN
    Test.startTest();
    Assert.areEqual(
      acctWrapper.isHighPriority(),
      true,
      'Expected to be High Priority Account');
    Test.stopTest();
  }
  @IsTest
  static void testisHighPriorityFalse() {
    // WHEN
    Account acct = [SELECT Id FROM Account WHERE Name = 'ACME'];
    AccountWrapper acctWrapper = new AccountWrapper(acct);
    // THEN
    Test.startTest();
    Assert.areEqual(
      acctWrapper.isHighPriority(),
      false,
      'Not Expected to be High Priority Account');
    Test.stopTest();
  }
    @IsTest
  static void testNegativeAccountWrapperAvgPriceOfOpps() {
    // GIVEN
    Account acct = [SELECT Id FROM Account WHERE Name = 'ACME'];
    List<Opportunity> opps = [
      SELECT Amount
      FROM Opportunity
      WHERE accountId = :acct.Id
    ];
    for (Opportunity o : opps) {
      o.Amount = 0;
    }
    update opps;
    AccountWrapper acctWrapper = new AccountWrapper(acct);
    // WHEN
    try {
      Test.startTest();
      acctWrapper.getRoundedAvgPriceOfOpps();
      Test.stopTest();
      Assert.fail('An exception should have been thrown');
    } catch (AccountWrapper.AWException e) {
      // THEN
      Assert.isTrue(
        e.getMessage().equalsIgnoreCase('no won opportunities'),
        'Exception message does not match: ' + e.getMessage()
      );
    }
  }
}