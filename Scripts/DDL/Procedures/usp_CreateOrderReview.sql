use eStore;

drop procedure if exists usp_CreateOrderReview;

delimiter $$
create procedure usp_CreateOrderReview(IN InJson JSON)
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
        OrderCode                   nvarchar(60),
        CompanyResponse             nvarchar(60),
        Rating                      smallint,
        Text                        nvarchar(120)
    );

    -- Insert the JSON data into the temporary table
    insert into tempJson (ClientLogin, OrderCode, CompanyResponse, Rating, Text)
    select 
            js.ClientLogin,
            js.OrderCode,
            COALESCE(js.CompanyResponse, 'pending'),
            js.Rating,
            js.Text
    from JSON_TABLE(InJson, '$' columns 
                        (
                            ClientLogin             nvarchar(60)    path N'$.Client.Login',
                            OrderCode               nvarchar(60)    path N'$.Order.Code',
                            CompanyResponse         nvarchar(60)    path N'$.CompanyResponse.Response',
                            Rating                  smallint        path N'$.Rating.Name',
                            Text                    nvarchar(120)   path N'$.OrderReview.Text'
                        ) 
            ) js;

  
    insert into OrderReview (ClientID, OrderID, CompanyResponseID, RatingID, Text)
    with cte_JsonData as (
            select 
                c.ClientID,
                o.OrderID,
                cr.CompanyResponseID,
                r.RatingID,
                tj.Text
                from tempJson tj
                inner join Client c ON c.Login = tj.ClientLogin
                inner join `Order` o ON o.`Code` = tj.OrderCode
                inner join CompanyResponse cr ON cr.`Name` = tj.CompanyResponse
                inner join Rating r ON r.`Name` = tj.Rating
                )
        select 
            ClientID,
            OrderID,
            CompanyResponseID,
            RatingID,
            Text
        from cte_JsonData;

END$$

DELIMITER ;
