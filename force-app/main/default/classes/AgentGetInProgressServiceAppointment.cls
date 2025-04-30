public with sharing class AgentGetInProgressServiceAppointment {

    public class InputVariables {
        @InvocableVariable(label='Action' description='The action that will be done. It should be "Get ServiceAppointment"' required=true)        
        public string action;

    }
    

    @InvocableMethod(label='Get In Progress Service Appointment' description='Get the current Service Appointment for a user')
    public static List<String> getCurrentServiceAppointment(List<InputVariables> userIds) {
        List<String> results = new List<String>();
        
        
        Id userId = UserInfo.getUserId(); 
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

        results.add('Service Appointment ID: ' + serviceAppointment.Id);
        results.add('Service Appointment Number: ' + serviceAppointment.AppointmentNumber);
        results.add('Service Appointment Status: ' + serviceAppointment.Status);
        results.add('Service Appointment Parent Record ID: ' + serviceAppointment.ParentRecordId);
        results.add('Service Appointment Earliest Start Time: ' + serviceAppointment.EarliestStartTime);
        results.add('Service Appointment Due Date: ' + serviceAppointment.DueDate);
        results.add('Service Appointment Sched Start Time: ' + serviceAppointment.SchedStartTime);
        results.add('Service Appointment Sched End Time: ' + serviceAppointment.SchedEndTime);
        results.add('Service Appointment City: ' + serviceAppointment.City);
        results.add('Service Appointment State: ' + serviceAppointment.State);
        results.add('Service Appointment PostalCode: ' + serviceAppointment.PostalCode);
        results.add('Service Appointment Country: ' + serviceAppointment.Country);
        

        // wenn ParentRecordId nicht null ist,und mit 0WO beginnt dann den WorkOrder abfragen
        string parentRecordId = String.valueOf(serviceAppointment.ParentRecordId);
        if (serviceAppointment.ParentRecordId != null && parentRecordId.startsWith('0WO')) {
            WorkOrder relatedWorkOrder = [SELECT Id, CaseId, Status, WorkTypeId, WorkType.Name FROM WorkOrder WHERE Id = :serviceAppointment.ParentRecordId LIMIT 1];

            if (relatedWorkOrder == null) {
                system.debug('No Work Order found for Service Appointment: ' + serviceAppointment.Id);
                return results; // Kein WorkOrder gefunden
            }
            results.add('Work Order ID: ' + relatedWorkOrder.Id);
            results.add('Work Order Status: ' + relatedWorkOrder.Status);
            results.add('Work Order Case ID: ' + relatedWorkOrder.CaseId);
            results.add('Work Order Work Type ID: ' + relatedWorkOrder.WorkTypeId);
            results.add('Work Order Work Type Name: ' + relatedWorkOrder.WorkType.Name);

            //Prüfen ob der workorder mit einem case verknüpft ist, wenn ja dann case abfragen und zurückgeben
            if (relatedWorkOrder.CaseId != null) {
                system.debug('Work Order has a related Case: ' + relatedWorkOrder.CaseId);
                Case relatedCase = [SELECT Id, Status, Subject, Priority, Origin, Description, CreatedDate, Contact.Name FROM Case WHERE Id = :relatedWorkOrder.CaseId LIMIT 1];
                if (relatedCase != null) {
                    results.add('Case ID: ' + relatedCase.Id);
                    results.add('Case Status: ' + relatedCase.Status);
                    results.add('Case Subject: ' + relatedCase.Subject);
                    results.add('Case Priority: ' + relatedCase.Priority);
                    results.add('Case Origin: ' + relatedCase.Origin);
                    results.add('Case Description: ' + relatedCase.Description);
                    results.add('Case Created Date: ' + relatedCase.CreatedDate);
                    results.add('Case Contact Name : ' + relatedCase.Contact.Name);
                }
            }
        }
        // Ergebnis zurückgeben
        system.debug('Results: ' + results);
        List<String> resultList = new List<String>();
        resultList.add(String.join(results, ', '));
        return resultList;


        
    }

    
}