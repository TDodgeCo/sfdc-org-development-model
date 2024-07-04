/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest()
public class NotificationServiceTest {

    private static Id createTestInstructor() {
        // Create a test instructor record
        Language_Course_Instructor__c instructor = new Language_Course_Instructor__c(Name = 'Test Instructor');
        insert instructor;
        return instructor.Id;
    }

    @IsTest(SeeAllData=true)
    static void testSendNotification() {
        // Create test data with required fields
        Id instructorId = createTestInstructor();
        // Create test data
        List<Language_Course__c> languageCourses = new List<Language_Course__c>{
            new Language_Course__c(Name = 'Spanish 101', Language_Course_Instructor__c = instructorId),
            new Language_Course__c(Name = 'French 101', Language_Course_Instructor__c = instructorId)
        };
        insert languageCourses;

        // Test sendNotification method
        Test.startTest();
        NotificationService.sendNotification(languageCourses, 'created');
        Test.stopTest();

        // Fetch Chatter posts
        List<FeedItem> feedItems = [SELECT Id, Body, ParentId FROM FeedItem WHERE ParentId IN :languageCourses];

        // Check that Chatter posts were created for each language course
        System.assertEquals(2, feedItems.size(), 'Two Chatter posts should be created.');

        // Check the content of the Chatter posts
        Map<Id, String> expectedMessages = new Map<Id, String>();
        expectedMessages.put(languageCourses[0].Id, 'Language Course created: Spanish 101');
        expectedMessages.put(languageCourses[1].Id, 'Language Course created: French 101');

        for (FeedItem feedItem : feedItems) {
            String expectedMessage = expectedMessages.get(feedItem.ParentId);
            System.assertNotEquals(null, expectedMessage, 'Unexpected FeedItem ParentId: ' + feedItem.ParentId);
            System.assert(feedItem.Body.contains(expectedMessage), 'FeedItem body should contain the expected message.');
        }
    }
}
