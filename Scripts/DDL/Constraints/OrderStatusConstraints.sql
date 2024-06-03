use eStore;

call usp_AddConstraintAlternateKey('AK_OrderStatus_Name', 'OrderStatus', '`Name`');

call usp_AddConstraintCheck('C_OrderStatus_Name', 'OrderStatus', 'LENGTH(TRIM(`Name`)) > 0');