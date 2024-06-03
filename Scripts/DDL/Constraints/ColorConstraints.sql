use eStore;

call usp_AddConstraintAlternateKey('AK_Color_Name', 'Color', '`Name`');

call usp_AddConstraintCheck('C_Color_Name', 'Color', 'LENGTH(TRIM(`Name`)) > 0');