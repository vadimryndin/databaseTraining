use eStore;

call usp_AddConstraintForeignKey('FK_Review_Client', 'OrderReview', 'ClientID', 'Client', 'ClientID');

call usp_AddConstraintForeignKey('FK_Review_Order', 'OrderReview', 'OrderID', 'Order', 'OrderID');

call usp_AddConstraintForeignKey('FK_Review_Rating', 'OrderReview', 'RatingID', 'Rating', 'RatingID');

call usp_AddConstraintForeignKey('FK_Review_Response', 'OrderReview', 'CompanyResponseID', 'CompanyResponse', 'CompanyResponseID');