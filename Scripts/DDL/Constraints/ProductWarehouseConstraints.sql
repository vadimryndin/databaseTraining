use eStore;

call usp_AddConstraintForeignKey('FK_ProductWarehouse_Product', 'ProductWarehouse', 'ProductID', 'Product', 'ProductID');

call usp_AddConstraintForeignKey('FK_ProductWarehouse_Warehouse', 'ProductWarehouse', 'WarehouseID', 'Warehouse', 'WarehouseID');
