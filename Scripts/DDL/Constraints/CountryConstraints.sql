use eStore;

call usp_AddConstraintAlternateKey('AK_Country_Name', 'Country', '`Name`');

call usp_AddConstraintCheck('C_Country_Name', 'Country', 'LENGTH(TRIM(`Name`)) > 0');