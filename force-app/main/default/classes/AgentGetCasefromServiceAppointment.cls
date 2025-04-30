public with sharing class AgentGetCasefromServiceAppointment {
    public class InputVariables {
        @InvocableVariable(label='ServiceaAppointmentID' description='The Id from the Serviceappointment' required=true)        
        public id ServiceaAppointmentID;
    }

        @InvocableMethod(label='Get the ID for the Case from a Serviceappointment' description='Return the ID for the Case from a Serviceappointment')
        public static List<Id> getCurrentServiceAppointmentId( List<InputVariables> Input) {
            List<id> results = new List<Id>();
            Id ServiceAppointmentId = Input[0].ServiceaAppointmentID; // Nur die erste Benutzer-ID verwenden
            system.debug(ServiceAppointmentId);

            //Service Appoint ment selectieren
            ServiceAppointment serviceAppointment = [
                SELECT Id,                        
                       ParentRecordId                      
                FROM ServiceAppointment
                WHERE Id = :ServiceAppointmentId
                LIMIT 1
            ];
            if (serviceAppointment == null) {
                system.debug('No Service Appointment found for user: ' + ServiceAppointmentId);
                return null; // Kein Servicetermin mit Status "In Progress" gefunden
            }
            //Work order selektieren
            WorkOrder workOrder = [
                SELECT Id,                        
                       CaseId           FROM WorkOrder
                WHERE Id = :serviceAppointment.ParentRecordId
                LIMIT 1
            ];

            if (workOrder == null) {
                system.debug('No Work Order found for user: ' + ServiceAppointmentId);
                return null; // Kein Servicetermin mit Status "In Progress" gefunden
            }
            
            results.add(workOrder.CaseId);

            return results;
    }
}