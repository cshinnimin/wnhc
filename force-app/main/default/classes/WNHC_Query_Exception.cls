public class WNHC_Query_Exception extends WNHC_Base_Exception {

    public WNHC_Query_Exception(Set<Id> idList, String errorMessage) {

        System.debug('WNHC_Query_Exception in' + errorMessage);
        
        // some kind of better error handling might be utilized
    }
}