use eStore;

call usp_AddConstraintAlternateKey('AK_Order_Code', 'Order', 'Code');

call usp_AddConstraintForeignKey('FK_Order_Status', 'Order', 'StatusID', 'OrderStatus', 'OrderStatusID');

call usp_AddConstraintForeignKey('FK_Order_PickUpPoint', 'Order', 'PickUpPointID', 'PickUpPoint', 'PickUpPointID');

call usp_AddConstraintForeignKey('FK_Order_Warehouse', 'Order', 'WarehouseID', 'Warehouse', 'WarehouseID');

call usp_AddConstraintForeignKey('FK_Order_Client', 'Order', 'ClientID', 'Client', 'ClientID');

call usp_AddConstraintCheck('C_Order_Code', 'Order', 'LENGTH(TRIM(Code)) > 0');

