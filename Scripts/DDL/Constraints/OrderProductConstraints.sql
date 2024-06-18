use eStore;

call usp_AddConstraintForeignKey('FK_OrderProduct_Order', 'OrderProduct', 'OrderID', 'Order', 'OrderID');

call usp_AddConstraintForeignKey('FK_OrderProduct_Product', 'OrderProduct', 'ProductID', 'Product', 'ProductID');
