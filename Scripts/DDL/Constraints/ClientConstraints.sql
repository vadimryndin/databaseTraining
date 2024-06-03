use eStore;

call usp_AddConstraintAlternateKey('AK_Client_Login', 'Client', 'Login');

call usp_AddConstraintUnique('UC_Client_PhoneNumber', 'Client', 'PhoneNumber');

call usp_AddConstraintUnique('UC_Client_Email', 'Client', 'Email');

call usp_AddConstraintForeignKey('FK_Client_Country', 'Client', 'CountryID', 'Country', 'CountryID');

call usp_AddConstraintForeignKey('FK_Client_PurchaseLevel', 'Client', 'PurchaseLevelID', 'PurchaseLevel', 'PurchaseLevelID');

call usp_AddConstraintCheck('C_Client_Login', 'Client', 'LENGTH(TRIM(Login)) > 0');

