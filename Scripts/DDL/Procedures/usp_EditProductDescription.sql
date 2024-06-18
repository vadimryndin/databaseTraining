USE eStore;

DROP PROCEDURE IF EXISTS usp_EditProductDescription;
DROP TEMPORARY TABLE IF EXISTS TempJsonData;

DELIMITER $$

CREATE PROCEDURE usp_EditProductDescription(IN InJson JSON)
BEGIN
    -- Declare variables
    DECLARE v_ProductID SMALLINT;
    DECLARE v_ColorID SMALLINT;
    DECLARE v_SizeID SMALLINT;

    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
        SELECT @p1, @p2;
    END;

    -- Create temporary table for JSON data
    CREATE TEMPORARY TABLE TempJsonData (
        ProductID SMALLINT,
        ProductName NVARCHAR(120),
        ProductCode CHAR(32),
        CatalogSectionName NVARCHAR(60),
        ProductPrice DECIMAL(10, 2),
        ProductWeight NVARCHAR(20),
        BrandName NVARCHAR(20),
        StateName NVARCHAR(60),
        ColorName NVARCHAR(20),
        SizeName NVARCHAR(20)
    );

    -- Insert JSON data into temporary table
    INSERT INTO TempJsonData
    SELECT 
        js.ProductID,
        js.ProductName,
        js.ProductCode,
        js.CatalogSectionName,
        js.ProductPrice,
        js.ProductWeight,
        js.BrandName,
        js.StateName,
        JSON_UNQUOTE(JSON_EXTRACT(js.Characteristics, '$[0].value')) AS ColorName,
        JSON_UNQUOTE(JSON_EXTRACT(js.Characteristics, '$[1].value')) AS SizeName
    FROM JSON_TABLE(InJson, '$' COLUMNS (
										ProductID SMALLINT PATH '$.Product.ProductID',
										ProductName NVARCHAR(120) PATH '$.Product.Name',
										ProductCode CHAR(32) PATH '$.Product.Code',
										CatalogSectionName NVARCHAR(60) PATH '$.CatalogSection.Name',
										ProductPrice NVARCHAR(60) PATH '$.Product.Price',
										ProductWeight NVARCHAR(60) PATH '$.Product.Weight',
										BrandName NVARCHAR(20) PATH '$.Brand.Name',
										StateName NVARCHAR(60) PATH '$.State.Name',
										Characteristics JSON PATH '$.Product.Characteristics'
    )) AS js;

    -- Get ColorID using temporary table
    SELECT ColorID INTO v_ColorID 
    FROM Color 
    WHERE Name = (SELECT ColorName FROM TempJsonData);

    -- Get SizeID using temporary table
    SELECT SizeID INTO v_SizeID 
    FROM Size 
    WHERE Name = (SELECT SizeName FROM TempJsonData);

    -- Update Product table
    UPDATE Product, TempJsonData
    SET 
        Product.`Name` = TempJsonData.ProductName,
        Product.`Code` = TempJsonData.ProductCode,
        Product.CatalogSectionID = (SELECT CatalogSectionID FROM CatalogSection WHERE Name = TempJsonData.CatalogSectionName),
        Product.Price = TempJsonData.ProductPrice,
        Product.Weight = TempJsonData.ProductWeight,
        Product.BrandID = (SELECT BrandID FROM Brand WHERE Name = TempJsonData.BrandName),
        Product.StateID = (SELECT StateID FROM State WHERE Name = TempJsonData.StateName),
        Product.ColorID = v_ColorID,
        Product.SizeID = v_SizeID
    WHERE Product.ProductID = TempJsonData.ProductID;

    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS TempJsonData;

END$$

DELIMITER ;
