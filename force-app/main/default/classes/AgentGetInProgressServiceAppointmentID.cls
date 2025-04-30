public with sharing class AgentGetInProgressServiceAppointmentID {
    public class InputVariables {
        @InvocableVariable(label='Action' description='The action that will be done' required=true)        
        public string action;

    }
    @InvocableMethod(label='Get the ID for the next Service Appointment' description='Get the ID for the next service appointment for a user')
    public static List<Id> getCurrentServiceAppointmentId( List<InputVariables> Input) {
        List<id> results = new List<Id>();
        
        
        Id userId = UserInfo.getUserId(); // Nur die erste Benutzer-ID verwenden
        system.debug(userId);

        // Überprüfen, ob eine Serviceresource für den Benutzer existiert
        ServiceResource serviceResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :userId LIMIT 1];

        if (serviceResource == null) {
            return null; // Benutzer hat keine Serviceresource
        }
        // Servicetermine abrufen, die dem Benutzer zugewiesen sind und den Status "In Progress" haben
        ServiceAppointment serviceAppointment = [
            SELECT Id, AppointmentNumber, 
                   Status, 
                   ParentRecordId,
                   EarliestStartTime,
                   DueDate,
                   SchedStartTime,
                   SchedEndTime,
                   City,
                   State,
                   PostalCode,
                   Country
            FROM ServiceAppointment
            WHERE Id IN (SELECT ServiceAppointmentId 
                         FROM AssignedResource WHERE ServiceResourceId = :serviceResource.Id)
            AND Status = 'In Progress'
            LIMIT 1
        ];

        if (serviceAppointment == null) {
            system.debug('No Service Appointment found for user: ' + userId);
            return null; // Kein Servicetermin mit Status "In Progress" gefunden
        }
        results.add(serviceAppointment.Id);
        return results;
    }
}