use eStore;

call usp_AddConstraintForeignKey('FK_AuthorizationEmployeeLog_Employee', 'AuthorizationEmployeeLog', 'EmployeeID', 'Employee', 'EmployeeID');

call usp_AddConstraintCheck('C_AuthorizationEmployeeLog_AuthorizationDateTime', 'AuthorizationEmployeeLog', 'AuthorizationDateTime <= SYSDATE()');

