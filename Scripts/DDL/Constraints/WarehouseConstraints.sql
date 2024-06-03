use eStore;

call usp_AddConstraintAlternateKey('AK_Warehouse_Name', 'Warehouse', '`Name`');

call usp_AddConstraintCheck('C_Warehouse_Name', 'Warehouse', 'LENGTH(TRIM(`Name`)) > 0');