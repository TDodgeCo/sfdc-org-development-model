trigger LanguageCourseTrigger on Language_Course__c (after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            NotificationService.sendNotification(Trigger.new, 'insert');
        } else if (Trigger.isUpdate) {
            NotificationService.sendNotification(Trigger.new, 'update');
        } else if (Trigger.isDelete) {
            NotificationService.sendEmailNotification(Trigger.old, 'delete');
        }
    }
}
