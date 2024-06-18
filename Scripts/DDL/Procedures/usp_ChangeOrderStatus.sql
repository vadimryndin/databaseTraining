use estore;

drop procedure if exists usp_ChangeOrderStatus;

delimiter $$

create procedure usp_ChangeOrderStatus(in InJson json)
begin
    -- declare variables
    declare v_ClientID smallint;
    declare v_OrderID smallint;
    declare v_NewStatusID smallint;
    
    -- error handling
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;

    start transaction;

    drop temporary table if exists tempJson;

    create temporary table tempJson (
        ClientLogin     nvarchar(60),
        OrderCode       char(32),
        NewStatus       nvarchar(60)
    );

    -- Insert JSON data into the temporary table
    insert into tempJson (ClientLogin, OrderCode, NewStatus)
    select
        js.ClientLogin,
        js.OrderCode,
        js.NewStatus
        from JSON_TABLE(InJson, '$' COLUMNS (
                                    ClientLogin         nvarchar(60)    path '$.Client.Login',
                                    OrderCode           char(32)        path '$.Order.Code',
                                    NewStatus           nvarchar(60)    path '$.NewStatus'
    )) as js;
 
    select c.ClientID, o.OrderID, s.OrderStatusID INTO v_ClientID, v_OrderID, v_NewStatusID
    from tempJson t
    inner join Client c ON c.Login = t.ClientLogin
    inner join `Order` o ON o.Code = t.OrderCode
    inner join OrderStatus s ON s.Name = t.NewStatus;

    -- Ensure ClientID is found
    IF v_ClientID IS NULL THEN
        select('Invalid Client Login.');
    END IF;

    -- Ensure OrderID is found
    IF v_OrderID IS NULL THEN
        select('Order not found for the given client.');
    END IF;

    -- Ensure NewStatusID is found
    IF v_NewStatusID IS NULL THEN
        select('Invalid Status.');
    END IF;

    -- update the Order status
    update `Order`
    set StatusID = v_NewStatusID
    where OrderID = v_OrderID;

    commit;
end$$

delimiter ;
