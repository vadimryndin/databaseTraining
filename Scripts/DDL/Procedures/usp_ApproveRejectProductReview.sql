use eStore;

drop procedure if exists usp_ApproveRejectProductReview;

delimiter $$
create procedure usp_ApproveRejectProductReview(IN InJson JSON)
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
        CompanyResponse             nvarchar(60)
    );

    -- Insert the JSON data into the temporary table
    insert into tempJson (ClientLogin, ProductCode, ProductBrand, CompanyResponse)
    select 
            js.ClientLogin,
            js.ProductCode,
            js.ProductBrand,
            js.CompanyResponse
    from JSON_TABLE(InJson, '$' columns 
                        (
                            ClientLogin             nvarchar(60)    path N'$.Client.Login',
                            ProductCode             nvarchar(60)    path N'$.Product.Code',
                            ProductBrand            nvarchar(60)    path N'$.Product.Brand',
                            CompanyResponse         nvarchar(60)    path N'$.CompanyResponse.Response'
                        ) 
            ) js;

    -- Update the CompanyResponse in ProductReview table
    update ProductReview orv
    join tempJson tj on orv.ClientID = (select ClientID from Client where Login = tj.ClientLogin)
                    and orv.ProductID = (select ProductID from Product where Code = tj.ProductCode 
                    and BrandID = (select BrandID from Brand where `Name` = tj.ProductBrand))
    set orv.CompanyResponseID = (select CompanyResponseID from CompanyResponse where `Name` = tj.CompanyResponse);

END$$

DELIMITER ;
