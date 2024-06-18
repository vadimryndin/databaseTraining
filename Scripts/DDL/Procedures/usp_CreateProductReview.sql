use eStore;

drop procedure if exists usp_CreateProductReview;

delimiter $$
create procedure usp_CreateProductReview(IN InJson JSON)
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
        CompanyResponse             nvarchar(60),
        Rating                      smallint,
        Text                        nvarchar(120),
        CreationDateTime            datetime
    );

    -- Insert the JSON data into the temporary table
    insert into tempJson (ClientLogin, ProductCode, ProductBrand, CompanyResponse, Rating, Text, CreationDateTime)
    select 
            js.ClientLogin,
            js.ProductCode,
            js.ProductBrand,
            COALESCE(js.CompanyResponse, 'pending'),
            js.Rating,
            js.Text,
            js.CreationDateTime
    from JSON_TABLE(InJson, '$' columns 
                        (
                            ClientLogin             nvarchar(60)    path N'$.Client.Login',
                            ProductCode             nvarchar(60)    path N'$.Product.Code',
                            ProductBrand            nvarchar(60)    path N'$.Product.Brand',
                            CompanyResponse         nvarchar(60)    path N'$.CompanyResponse.Response',
                            Rating                  smallint        path N'$.Rating.Name',
                            Text                    nvarchar(120)   path N'$.ProductReview.Text',
                            CreationDateTime        datetime        path N'$.ProductReview.CreationDateTime'
                        ) 
            ) js;

  
    insert into ProductReview (ClientID, ProductID, CompanyResponseID, RatingID, Text, CreationDateTime)
    with cte_JsonData as (
            select 
                c.ClientID,
                o.ProductID,
                cr.CompanyResponseID,
                r.RatingID,
                tj.Text,
                tj.CreationDateTime
                from tempJson tj
                inner join Client c ON c.Login = tj.ClientLogin
                inner join `Product` o ON o.`Code` = tj.ProductCode
                inner join Brand b on b.Name = tj.ProductBrand
                inner join CompanyResponse cr ON cr.`Name` = tj.CompanyResponse
                inner join Rating r ON r.`Name` = tj.Rating
                )
        select 
            ClientID,
            ProductID,
            CompanyResponseID,
            RatingID,
            Text,
            CreationDateTime
        from cte_JsonData;

END$$

DELIMITER ;
