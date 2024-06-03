use eStore;

call usp_AddConstraintAlternateKey('AK_PurchaseLevel_Name', 'PurchaseLevel', '`Name`');

call usp_AddConstraintCheck('C_PurchaseLevel_Name', 'PurchaseLevel', 'LENGTH(TRIM(`Name`)) > 0');