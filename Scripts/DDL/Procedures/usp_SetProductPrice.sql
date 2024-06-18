USE eStore;

DROP PROCEDURE IF EXISTS usp_SetProductPrice;

DELIMITER $$

CREATE PROCEDURE usp_SetProductPrice(IN InJson JSON)
BEGIN
    -- Declare variables
    DECLARE v_ProductID SMALLINT;
    DECLARE v_NewPrice SMALLINT;

    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
        SELECT @p1, @p2;
    END;

    -- Extract values from JSON input
    SET v_ProductID = JSON_UNQUOTE(JSON_EXTRACT(InJson, '$.Product.ProductID'));
    SET v_NewPrice = JSON_UNQUOTE(JSON_EXTRACT(InJson, '$.NewPrice'));

    -- Update the price of the product
    UPDATE Product
    SET Price = v_NewPrice
    WHERE ProductID = v_ProductID;
END$$

DELIMITER ;
