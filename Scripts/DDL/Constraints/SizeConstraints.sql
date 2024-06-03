use eStore;

call usp_AddConstraintAlternateKey('AK_Size_Name', 'Size', '`Name`');

call usp_AddConstraintCheck('C_Size_Name', 'Size', 'LENGTH(TRIM(`Name`)) > 0');