/// Status utility functions for managing PR/PO status display and logic
class StatusUtils {
  /// Maps backend status to display status
  /// 'transformed' displays as 'approved' in UI (indicates successful conversion)
  /// 'edited' displays as 'pending' in UI for POs
  static String getDisplayStatus(String? status) {
    if (status == null || status.isEmpty) return '';
    final statusLower = status.toLowerCase().trim();
    
    // 'transformed' indicates PR was converted to PO, displays as 'approved'
    if (statusLower == 'transformed') return 'approved';
    
    // 'edited' for POs displays as 'pending' for role 6 (accountant)
    if (statusLower == 'edited') return 'pending';
    
    return statusLower;
  }
  
  /// Checks if a status represents a pending-like state (for filtering/logic)
  /// Returns true if status is 'pending', 'transformed', or 'edited'
  static bool isPendingLike(String? status) {
    if (status == null || status.isEmpty) return false;
    final statusLower = status.toLowerCase().trim();
    return statusLower == 'pending' || 
           statusLower == 'transformed' || 
           statusLower == 'edited';
  }
  
  /// Checks if a status is the actual 'pending' status (not converted or edited)
  static bool isPending(String? status) {
    if (status == null || status.isEmpty) return false;
    return status.toLowerCase().trim() == 'pending';
  }
  
  /// Checks if a status is 'converted' (PR converted to PO)
  static bool isConverted(String? status) {
    if (status == null || status.isEmpty) return false;
    return status.toLowerCase().trim() == 'converted';
  }
  
  /// Checks if a status is approved
  static bool isApproved(String? status) {
    if (status == null || status.isEmpty) return false;
    return status.toLowerCase().trim() == 'approved';
  }
  
  /// Checks if a status is rejected
  static bool isRejected(String? status) {
    if (status == null || status.isEmpty) return false;
    return status.toLowerCase().trim() == 'rejected';
  }
}
