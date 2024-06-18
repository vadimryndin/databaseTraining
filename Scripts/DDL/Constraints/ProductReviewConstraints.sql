use eStore;

call usp_AddConstraintForeignKey('FK_Review_Client', 'ProductReview', 'ClientID', 'Client', 'ClientID');

call usp_AddConstraintForeignKey('FK_Review_Product', 'ProductReview', 'ProductID', 'Product', 'ProductID');

call usp_AddConstraintForeignKey('FK_Review_Rating', 'ProductReview', 'RatingID', 'Rating', 'RatingID');

call usp_AddConstraintForeignKey('FK_Review_Response', 'ProductReview', 'CompanyResponseID', 'CompanyResponse', 'CompanyResponseID');