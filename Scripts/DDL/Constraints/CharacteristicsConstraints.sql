use eStore;

call usp_AddConstraintForeignKey('FK_Characteristics_Product', 'Characteristics', 'ProductID', 'Product', 'ProductID');

call usp_AddConstraintForeignKey('FK_Characteristics_Color', 'Characteristics', 'ColorID', 'Color', 'ColorID');

call usp_AddConstraintForeignKey('FK_Characteristics_Size', 'Characteristics', 'SizeID', 'Size', 'SizeID');