use eStore;

drop procedure if exists usp_AddProductToBasket;

delimiter $$
create procedure usp_AddProductToBasket(IN InJson JSON)
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
        ClientLogin                 nvarchar(60),
        ProductCode                 nvarchar(60),
        ProductBrand                nvarchar(60),
        ProductQuantity             int
    );

    -- Insert the JSON data into the temporary table
    insert into tempJson (ClientLogin, ProductCode, ProductBrand, ProductQuantity)
    select 
            js.ClientLogin,
            js.ProductCode,
            js.ProductBrand,
            js.ProductQuantity
    from JSON_TABLE(InJson, '$' columns 
                        (
                            ClientLogin             nvarchar(60) path N'$.Client.Login',
                            ProductCode             nvarchar(60) path N'$.Product.Code',
                            ProductBrand            nvarchar(60) path N'$.Product.Brand',
                            ProductQuantity         int          path N'$.Quantity'
                        ) 
            ) js;

  
    insert into Basket (ClientID, ProductID, ProductQuantity)
    with cte_JsonData as (
            select 
                c.ClientID,
                p.ProductID,
                tj.ProductQuantity
                from tempJson tj
                inner join Client c ON c.Login = tj.ClientLogin
                inner join Brand b ON b.Name = tj.ProductBrand
                inner join Product p ON p.Code = tj.ProductCode and p.BrandID = b.BrandID
                )
        select 
            ClientID,
            ProductID,
            ProductQuantity
        from cte_JsonData
        ON DUPLICATE KEY UPDATE ProductQuantity = cte_JsonData.ProductQuantity;

END$$

DELIMITER ;
