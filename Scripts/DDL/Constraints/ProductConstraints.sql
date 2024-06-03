use eStore;

call usp_AddConstraintAlternateKey('AK_Product_Code', 'Product', 'Code');

call usp_AddConstraintAlternateKey('AK_Product_Brand', 'Product', 'BrandID');

call usp_AddConstraintForeignKey('FK_Product_Brand', 'Product', 'BrandID', 'Brand', 'BrandID');

call usp_AddConstraintForeignKey('FK_Product_State', 'Product', 'StateID', 'State', 'StateID');

call usp_AddConstraintForeignKey('FK_Product_CatalogSection', 'Product', 'CatalogSectionID', 'CatalogSection', 'CatalogSectionID');

call usp_AddConstraintCheck('C_Product_Code', 'Product', 'LENGTH(TRIM(Code)) > 0');

