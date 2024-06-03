use eStore;

call usp_AddConstraintAlternateKey('AK_State_Name', 'State', '`Name`');

call usp_AddConstraintCheck('C_State_Name', 'State', 'LENGTH(TRIM(`Name`)) > 0');