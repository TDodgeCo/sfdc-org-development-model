public class NotificationService {
    public static void sendNotification(List<Language_Course__c> courses, String operation) {
        if (operation == 'delete') {
            sendEmailNotification(courses);
        } else {
            sendChatterNotification(courses, operation);
        }
    }

    private static void sendChatterNotification(List<Language_Course__c> courses, String operation) {
        List<FeedItem> feedItems = new List<FeedItem>();
        for (Language_Course__c course : courses) {
            FeedItem feedItem = new FeedItem();
            feedItem.ParentId = course.Id;
            feedItem.Body = 'Language Course ' + operation + ': ' + course.Name;
            feedItems.add(feedItem);
        }
        insert feedItems;
    }

    private static void sendEmailNotification(List<Language_Course__c> courses) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Language_Course__c course : courses) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { 'timldodge@gmail.com' }); // Replace with actual recipient email
            email.setSubject('Language Course Deleted: ' + course.Name);
            email.setPlainTextBody('The following language course has been deleted: ' + course.Name);
            emails.add(email);
        }
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}
