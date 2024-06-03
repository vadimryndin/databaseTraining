use eStore;

call usp_AddConstraintAlternateKey('AK_Employee_Login', 'Employee', 'Login');

call usp_AddConstraintUnique('UC_Employee_PhoneNumber', 'Employee', 'PhoneNumber');

call usp_AddConstraintForeignKey('FK_Employee_JobPosition', 'Employee', 'JobPositionID', 'JobPosition', 'JobPositionID');

call usp_AddConstraintForeignKey('FK_Employee_SystemRole', 'Employee', 'SystemRoleID', 'SystemRole', 'SystemRoleID');

call usp_AddConstraintForeignKey('FK_Employee_Administrator', 'Employee', 'CreatorAdministratorID', 'Administrator', 'AdministratorID');

call usp_AddConstraintCheck('C_Employee_Login', 'Employee', 'LENGTH(TRIM(Login)) > 0');

call usp_AddConstraintCheck('C_Employee_ContractExpirationDate', 'Employee', 'ContractExpirationDate > DATE(SYSDATE())');

