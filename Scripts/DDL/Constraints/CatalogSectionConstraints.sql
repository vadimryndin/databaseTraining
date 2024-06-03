use eStore;

call usp_AddConstraintAlternateKey('AK_CatalogSection_Name', 'CatalogSection', '`Name`');

call usp_AddConstraintCheck('C_CatalogSection_Name', 'CatalogSection', 'LENGTH(TRIM(`Name`)) > 0');

call usp_AddConstraintForeignKey('FK_CatalogSection_CatalogSection', 'CatalogSection', 'ParentSectionID', 'CatalogSection', 'CatalogSectionID');