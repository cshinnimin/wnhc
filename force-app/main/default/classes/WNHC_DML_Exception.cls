public class WNHC_DML_Exception extends WNHC_Base_Exception {

    public WNHC_DML_Exception(List<Object> sObjectList, String errorMessage) {

        System.debug('WNHC_DML_Exception in' + errorMessage);
        
        // some kind of better error handling might be utilized
    }
}