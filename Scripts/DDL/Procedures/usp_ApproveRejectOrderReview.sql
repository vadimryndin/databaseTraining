use eStore;

drop procedure if exists usp_ApproveRejectOrderReview;

delimiter $$
create procedure usp_ApproveRejectOrderReview(IN InJson JSON)
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
        CompanyResponse             nvarchar(60)
    );

    -- Insert the JSON data into the temporary table
    insert into tempJson (ClientLogin, OrderCode, CompanyResponse)
    select 
            js.ClientLogin,
            js.OrderCode,
            js.CompanyResponse
    from JSON_TABLE(InJson, '$' columns 
                        (
                            ClientLogin             nvarchar(60)    path N'$.Client.Login',
                            OrderCode               nvarchar(60)    path N'$.Order.Code',
                            CompanyResponse         nvarchar(60)    path N'$.CompanyResponse.Response'
                        ) 
            ) js;

    -- Update the CompanyResponse in OrderReview table
    update OrderReview orv
    join tempJson tj ON orv.ClientID = (select ClientID from Client where Login = tj.ClientLogin)
                    AND orv.OrderID = (select OrderID from `Order` where Code = tj.OrderCode)
    set orv.CompanyResponseID = (select CompanyResponseID from CompanyResponse where Name = tj.CompanyResponse);

END$$

DELIMITER ;
