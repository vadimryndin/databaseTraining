use eStore;

call usp_AddConstraintAlternateKey('AK_JobPosition_Name', 'JobPosition', '`Name`');

call usp_AddConstraintCheck('C_JobPosition_Name', 'JobPosition', 'LENGTH(TRIM(`Name`)) > 0');


