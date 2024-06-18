USE eStore;

DROP PROCEDURE IF EXISTS usp_AddProductDescription;

DELIMITER $$

CREATE PROCEDURE usp_AddProductDescription(IN InJson JSON)
BEGIN
    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
        SELECT @p1, @p2;
    END;

    -- Create temporary table for JSON data
    CREATE TEMPORARY TABLE TempJsonData (
            ProductName             NVARCHAR(120),
            ProductCode             CHAR(32),
            CatalogSectionName      NVARCHAR(60),
            ProductPrice            DECIMAL(10, 2),
            ProductWeight           NVARCHAR(60),
            BrandName               NVARCHAR(20),
            StateName               NVARCHAR(60),
            ColorName               NVARCHAR(20),
            SizeName                NVARCHAR(20)
    );

    -- Insert JSON data into temporary table
    INSERT INTO TempJsonData
    SELECT 
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
                                        ProductName         NVARCHAR(120)   PATH '$.Product.Name',
                                        ProductCode         CHAR(32)        PATH '$.Product.Code',
                                        CatalogSectionName  NVARCHAR(60)    PATH '$.CatalogSection.Name',
                                        ProductPrice        NVARCHAR(60)    PATH '$.Product.Price',
                                        ProductWeight       NVARCHAR(60)    PATH '$.Product.Weight',
                                        BrandName           NVARCHAR(20)    PATH '$.Brand.Name',
                                        StateName           NVARCHAR(60)    PATH '$.State.Name',
                                        Characteristics     JSON            PATH '$.Product.Characteristics'
    )) AS js;

    -- Insert into Product table
    INSERT INTO Product (`Name`, `Code`, CatalogSectionID, Price, Weight, BrandID, StateID, ColorID, SizeID)
    SELECT 
        ProductName,
        ProductCode,
        (SELECT CatalogSectionID FROM CatalogSection WHERE Name = CatalogSectionName),
        ProductPrice,
        ProductWeight,
        (SELECT BrandID FROM Brand WHERE Name = BrandName),
        (SELECT StateID FROM State WHERE Name = StateName),
        (SELECT ColorID FROM Color WHERE Name = ColorName),
        (SELECT SizeID FROM Size WHERE Name = SizeName)
    FROM TempJsonData;

    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS TempJsonData;

END$$

DELIMITER ;
