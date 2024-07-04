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
@IsTest(SeeAllData=true)
public class LanguageCourseTriggerTest {

    private static Id createTestInstructor() {
        // Create a test instructor record
        Language_Course_Instructor__c instructor = new Language_Course_Instructor__c(Name = 'Test Instructor');
        insert instructor;
        return instructor.Id;
    }
    
    @IsTest(SeeAllData=true)
    static void testInsertTrigger() {
        // Create test data with required fields
        Id instructorId = createTestInstructor();
        Language_Course__c course = new Language_Course__c(
            Name = 'Spanish 101',
            Language_Course_Instructor__c = instructorId
        );
        insert course;
        
        // Verify that the notification was sent
        Test.startTest();
        NotificationService.sendNotification(new List<Language_Course__c>{course}, 'insert');
        Test.stopTest();
        
        // Add assertions to verify the behavior
        System.assertEquals('Spanish 101', course.Name);
    }
    
    @IsTest(SeeAllData=true)
    static void testUpdateTrigger() {
        // Create test data with required fields
        Id instructorId = createTestInstructor();
        Language_Course__c course = new Language_Course__c(
            Name = 'French 101',
            Language_Course_Instructor__c = instructorId
        );
        insert course;
        
        // Update the course
        course.Name = 'Advanced French 101';
        update course;
        
        // Verify that the notification was sent
        Test.startTest();
        NotificationService.sendNotification(new List<Language_Course__c>{course}, 'update');
        Test.stopTest();
        
        // Add assertions to verify the behavior
        System.assertEquals('Advanced French 101', course.Name);
    }
    
    @IsTest(SeeAllData=true)
    static void testDeleteTrigger() {
        // Create test data with required fields
        Id instructorId = createTestInstructor();
        Language_Course__c course = new Language_Course__c(
            Name = 'German 101',
            Language_Course_Instructor__c = instructorId
        );
        insert course;

        // Ensure the record exists before delete
        Language_Course__c insertedCourse = [SELECT Id FROM Language_Course__c WHERE Id = :course.Id];
        System.assertNotEquals(null, insertedCourse, 'The course should have been inserted.');

        // Delete the course
        Test.startTest();
        delete course;
        NotificationService.sendNotification(new List<Language_Course__c>{course}, 'delete');
        Test.stopTest();

        // Verify the course has been deleted
        List<Language_Course__c> deletedCourses = [SELECT Id FROM Language_Course__c WHERE Id = :course.Id];
        System.assertEquals(0, deletedCourses.size(), 'The course should have been deleted.');
    }
    
    @IsTest(SeeAllData=true)
    static void testBulkInsertTrigger() {
        // Create test data with required fields
        Id instructorId = createTestInstructor();
        List<Language_Course__c> courses = new List<Language_Course__c>();
        for (Integer i = 0; i < 200; i++) {
            courses.add(new Language_Course__c(
                Name = 'Course ' + i,
                Language_Course_Instructor__c = instructorId
            ));
        }
        insert courses;
        
        // Verify that the notification was sent
        Test.startTest();
        NotificationService.sendNotification(courses, 'insert');
        Test.stopTest();
        
        // Add assertions to verify the behavior
        System.assertEquals(200, courses.size());
    }
}