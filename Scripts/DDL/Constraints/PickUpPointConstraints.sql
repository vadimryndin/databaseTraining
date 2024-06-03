use eStore;

call usp_AddConstraintAlternateKey('AK_PickUpPoint_Name', 'PickUpPoint', '`Name`');

call usp_AddConstraintCheck('C_PickUpPoint_Name', 'PickUpPoint', 'LENGTH(TRIM(`Name`)) > 0');