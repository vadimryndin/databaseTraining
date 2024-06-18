use eStore;

call usp_AddConstraintForeignKey('FK_ProductPickUpPoint_Product', 'ProductPickUpPoint', 'ProductID', 'Product', 'ProductID');

call usp_AddConstraintForeignKey('FK_ProductPickUpPoint_PickUpPoint', 'ProductPickUpPoint', 'PickUpPointID', 'PickUpPoint', 'PickUpPointID');
