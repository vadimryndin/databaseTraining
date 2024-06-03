use eStore;

call usp_AddConstraintAlternateKey('AK_Administrator_Login', 'Administrator', 'Login');

call usp_AddConstraintCheck('C_Administrator_Login', 'Administrator', 'LENGTH(TRIM(Login)) > 0');


