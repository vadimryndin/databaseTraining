use eStore;

call usp_AddConstraintAlternateKey('AK_CompanyResponse_Name', 'CompanyResponse', '`Name`');

call usp_AddConstraintCheck('C_CompanyResponse_Name', 'CompanyResponse', 'LENGTH(TRIM(`Name`)) > 0');