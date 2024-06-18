use eStore;

drop procedure if exists usp_SetProductQuantity;

delimiter $$
create procedure usp_SetProductQuantity(IN InJson JSON)
begin
    -- describe reaction on error
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;

    -- Create a temporary table to hold the JSON data
    drop table if exists tempJson;
    create temporary table tempJson (
        ProductName                 nvarchar(60),
        ProductCode                 nvarchar(60),
        WarehouseName               nvarchar(60),
        WarehouseProductQuantity    int,
        PickUpPointName             nvarchar(60),
        PickUpPointProductQuantity  int
    );

    -- Insert the JSON data into the temporary table
    insert into tempJson (ProductName, ProductCode, WarehouseName, WarehouseProductQuantity, PickUpPointName, PickUpPointProductQuantity)
    select 
            js.ProductName,
            js.ProductCode,
            js.WarehouseName,
            js.WarehouseProductQuantity,
            js.PickUpPointName,
            js.PickUpPointProductQuantity
    from JSON_TABLE(InJson, '$' columns 
                        (
                            ProductName                 nvarchar(60) path N'$.Product.Name',
                            ProductCode                 nvarchar(60) path N'$.Product.Code',
                            WarehouseName               nvarchar(60) path N'$.Warehouse.Name',
                            WarehouseProductQuantity    int          path N'$.Warehouse.ProductQuantity',
                            PickUpPointName             nvarchar(60) path N'$.PickUpPoint.Name',
                            PickUpPointProductQuantity  int          path N'$.PickUpPoint.ProductQuantity'
                        ) 
            ) js;

  
    insert into ProductWarehouse (ProductID, WarehouseID, ProductQuantity)
    with cte_JsonData as (
            select 
                p.ProductID,
                w.WarehouseID,
                jd.WarehouseProductQuantity
                from tempJson jd
                inner join Product p ON p.Name = jd.ProductName and p.Code = jd.ProductCode
                inner join Warehouse w ON w.Name = jd.WarehouseName
                )
        select 
            ProductID,
            WarehouseID,
            WarehouseProductQuantity
        from cte_JsonData
        ON DUPLICATE KEY UPDATE ProductQuantity = cte_JsonData.WarehouseProductQuantity;
    
    insert into ProductPickUpPoint (ProductID, PickUpPointID, ProductQuantity)
    with cte_JsonData as (
            select 
                p.ProductID,
                w.PickUpPointID,
                jd.PickUpPointProductQuantity
                from tempJson jd
                inner join Product p ON p.Name = jd.ProductName and p.Code = jd.ProductCode
                inner join PickUpPoint w ON w.Name = jd.PickUpPointName
                )
        select 
            ProductID,
            PickUpPointID,
            PickUpPointProductQuantity
        from cte_JsonData
        ON DUPLICATE KEY UPDATE ProductQuantity = cte_JsonData.PickUpPointProductQuantity;

END$$

DELIMITER ;
