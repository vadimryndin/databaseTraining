use eStore;

call usp_AddConstraintForeignKey('FK_Basket_Brand', 'Basket', 'ClientID', 'Client', 'ClientID');

call usp_AddConstraintForeignKey('FK_Basket_State', 'Basket', 'ProductID', 'Product', 'ProductID');
