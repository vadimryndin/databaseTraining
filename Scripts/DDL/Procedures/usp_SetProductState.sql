USE eStore;

DROP PROCEDURE IF EXISTS usp_SetProductState;

DELIMITER $$

CREATE PROCEDURE usp_SetProductState(IN InJson JSON)
BEGIN
    -- Declare variables
    DECLARE v_ProductID SMALLINT;
    DECLARE v_NewState  NVARCHAR(60);

    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
        SELECT @p1, @p2;
    END;

    -- Extract values from JSON input
    SET v_ProductID = JSON_UNQUOTE(JSON_EXTRACT(InJson, '$.Product.ProductID'));
    SET v_NewState = JSON_UNQUOTE(JSON_EXTRACT(InJson, '$.NewState'));

    -- Update the state of the product
    UPDATE Product AS p
    INNER JOIN State AS s ON s.Name = v_NewState
    SET p.StateID = s.StateID
    WHERE p.ProductID = v_ProductID;

END$$

DELIMITER ;
