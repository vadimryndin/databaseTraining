use eStore;

call usp_AddConstraintAlternateKey('AK_SystemRole_Name', 'SystemRole', '`Name`');

call usp_AddConstraintCheck('C_SystemRole_Name', 'SystemRole', 'LENGTH(TRIM(`Name`)) > 0');


