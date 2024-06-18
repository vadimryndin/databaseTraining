use eStore;

drop procedure if exists usp_CreateOrder;

delimiter $$
create procedure usp_CreateOrder(IN InJson JSON)
proc_body:
begin
    -- Declare variables
    declare v_OrderID               smallint;
    declare v_ClientID              smallint;
    declare v_FinalCost             int;
    declare v_TotalQuantity         int;
    declare v_StatusID              smallint    default 1;
    declare v_PickUpPointID         smallint;
    declare v_WarehouseID           smallint;
    declare v_InsufficientQuantity  bool        default false;

    -- describe reaction on error
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
        -- unsuccessful end of transaction
        rollback;
    end;

    start transaction;

    -- Drop the intermediate table if it exists
    drop table if exists intermediateJson;

    -- Create the intermediate table to hold the JSon data
    create table intermediateJson (
        ClientLogin          nvarchar(60),
        OrderCode            char(32),
        CreationDateTime     datetime,
        ShelfLife            datetime,
        ProductCode          char(32),
        ProductBrand         nvarchar(60),
        ProductQuantity      int,
        PickUpPointName      nvarchar(60),
        WarehouseName        nvarchar(60)
    );

    -- Insert the JSon data into the intermediate table
    insert into intermediateJson (ClientLogin, OrderCode, CreationDateTime, ShelfLife, ProductCode, ProductBrand, ProductQuantity, PickUpPointName, WarehouseName)
    select 
        js.ClientLogin,
        js.OrderCode,
        js.CreationDateTime,
        js.ShelfLife,
        prod.Code,
        prod.Brand,
        prod.Quantity,
        js.PickUpPointName,
        js.WarehouseName
    from JSON_TABLE(InJson, '$' COLUMNS (
                                    ClientLogin         nvarchar(60)    path '$.Client.Login',
                                    OrderCode           char(32)        path '$.Order.Code',
                                    CreationDateTime    datetime        path '$.Order.CreationDateTime',
                                    ShelfLife           datetime        path '$.Order.StoreUpToDateTime',
                                    Products            JSON            path '$.Products',
                                    PickUpPointName     nvarchar(60)    path '$.PickUpPoint.Name',
                                    WarehouseName       nvarchar(60)    path '$.Warehouse.Name'
    )) as js
    cross join JSON_TABLE(js.Products, '$[*]' COLUMNS (
                                                    Code        char(32)        path '$.Code',
                                                    Brand       nvarchar(60)    path '$.Brand',
                                                    Quantity    int             path '$.Quantity'
    )) as prod;

    -- Retrieve ClientID
    select ClientID into v_ClientID
    from Client
    where Login = (select ClientLogin from intermediateJson LIMIT 1);

    -- Calculate total quantity and final cost
    select SUM(ProductQuantity), SUM(ProductQuantity * p.Price)
    into v_TotalQuantity, v_FinalCost
    from intermediateJson ij
    join Product p on p.Code = ij.ProductCode and p.BrandID = (select BrandID from Brand where Name = ij.ProductBrand);

    -- Retrieve PickUpPointID and WarehouseID
    select PickUpPointID into v_PickUpPointID
    from PickUpPoint
    where Name = (select PickUpPointName from intermediateJson limit 1);

    select WarehouseID into v_WarehouseID
    from Warehouse
    where Name = (select WarehouseName from intermediateJson limit 1);

    -- Check if there's enough quantity in ProductWarehouse
    if v_WarehouseID is not null then
        if not exists (
            select 1
            from ProductWarehouse pw
            join (
                select ProductID, SUM(ProductQuantity) as TotalProductQuantity
                from intermediateJson ij
                join Product p on p.Code = ij.ProductCode and p.BrandID = (select BrandID from Brand where Name = ij.ProductBrand)
                where ij.WarehouseName is not null
                group by ProductID
            ) as ij on pw.ProductID = ij.ProductID
            where pw.ProductQuantity >= ij.TotalProductQuantity and pw.WarehouseID = v_WarehouseID
        ) then
            set v_InsufficientQuantity = TRUE;
        end if;
    end if;

    -- Check if there's enough quantity in ProductPickUpPoint
    if v_PickUpPointID is not null then
        if not exists (
            select 1
            from ProductPickUpPoint pp
            join (
                select ProductID, SUM(ProductQuantity) as TotalProductQuantity
                from intermediateJson ij
                join Product p on p.Code = ij.ProductCode and p.BrandID = (select BrandID from Brand where Name = ij.ProductBrand)
                where ij.PickUpPointName is not null
                group by ProductID
            ) as ij on pp.ProductID = ij.ProductID
            where pp.ProductQuantity >= ij.TotalProductQuantity and pp.PickUpPointID = v_PickUpPointID
        ) then
            set v_InsufficientQuantity = TRUE;
        end if;
    end if;

    -- if insufficient quantity, rollback and signal error
    if v_InsufficientQuantity 
    then
        select 'Insufficient quantity in the warehouse or pickup point.';
        leave proc_body;
    end if;

    -- Insert the order
    insert into `Order` (`Code`, CreationDateTime, ShelfLife, FinalCost, StatusID, PickUpPointID, WarehouseID, ClientID, Quantity, Cost)
    values (
        (select OrderCode from intermediateJson LIMIT 1),
        (select CreationDateTime from intermediateJson LIMIT 1),
        (select ShelfLife from intermediateJson LIMIT 1),
        v_FinalCost,
        v_StatusID,
        v_PickUpPointID,
        v_WarehouseID,
        v_ClientID,
        v_TotalQuantity,
        v_FinalCost
    );

    -- Retrieve the OrderID using the unique OrderCode
    select OrderID into v_OrderID
    from `Order`
    where Code = (select OrderCode from intermediateJson limit 1)
    order by OrderID DESC
    limit 1;

    -- Insert into OrderProduct table
    insert into OrderProduct (OrderID, ProductID, ProductPrice, ProductQuantity, DiscountValue)
    select
        v_OrderID,
        p.ProductID,
        p.Price,
        ij.ProductQuantity,
        null
    from intermediateJson ij
    join Product p on p.Code = ij.ProductCode and p.BrandID = (select BrandID from Brand where Name = ij.ProductBrand);

    -- Update ProductWarehouse quantities
    update ProductWarehouse pw
    join (
        select ProductID, SUM(ProductQuantity) as TotalProductQuantity
        from intermediateJson ij
        join Product p on p.Code = ij.ProductCode and p.BrandID = (select BrandID from Brand where Name = ij.ProductBrand)
        where ij.WarehouseName is not null
        group by ProductID
    ) as ij
    on pw.ProductID = ij.ProductID
    set pw.ProductQuantity = pw.ProductQuantity - ij.TotalProductQuantity
    where pw.ProductQuantity >= ij.TotalProductQuantity and pw.WarehouseID = v_WarehouseID;

    -- Update ProductPickUpPoint quantities
    update ProductPickUpPoint pp
    join (
        select ProductID, SUM(ProductQuantity) as TotalProductQuantity
        from intermediateJson ij
        join Product p on p.Code = ij.ProductCode and p.BrandID = (select BrandID from Brand where Name = ij.ProductBrand)
        where ij.PickUpPointName is not null
        group by ProductID
    ) as ij
    on pp.ProductID = ij.ProductID
    set pp.ProductQuantity = pp.ProductQuantity - ij.TotalProductQuantity
    where pp.ProductQuantity >= ij.TotalProductQuantity and pp.PickUpPointID = v_PickUpPointID;

    -- Remove ordered products from basket
    delete from Basket
    where ClientID = v_ClientID
      and ProductID in (select ProductID from intermediateJson ij 
      join Product p on p.Code = ij.ProductCode and p.BrandID = (select BrandID from Brand where Name = ij.ProductBrand));

    -- Drop the intermediate table
    drop table if exists intermediateJson;

    -- Commit the transaction
    commit;
end$$

delimiter ;
