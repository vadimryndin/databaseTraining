use eStore;

call usp_AddConstraintAlternateKey('AK_Brand_Name', 'Brand', '`Name`');

call usp_AddConstraintCheck('C_Brand_Name', 'Brand', 'LENGTH(TRIM(`Name`)) > 0');