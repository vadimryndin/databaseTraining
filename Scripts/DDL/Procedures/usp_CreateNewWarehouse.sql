use eStore;

drop procedure if exists usp_CreateNewWarehouse;

delimiter $$
create procedure usp_CreateNewWarehouse(in InJson json)
proc_body:
begin
    -- describe reaction on error
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;
    -- create new Warehouse
    insert into Warehouse (`Name`, Address, OpeningHours)
    with cte_JsonData (`Name`, Address, OpeningHours) as
    (
        select js.`Name`,
               js.Address,
               js.OpeningHours
        from JSON_TABLE(InJson, '$' columns 
                                (
                                    `Name`          nvarchar(60)   path N'$.Warehouse.Name',
                                    Address         nvarchar(255)  path N'$.Warehouse.Address',
                                    OpeningHours    nvarchar(255)  path N'$.Warehouse.OpeningHours'
                                ) 
                        ) js
    )
    select cte_JsonData.`Name`,
           cte_JsonData.Address,
           cte_JsonData.OpeningHours
    from cte_JsonData left outer join
         Warehouse on (cte_JsonData.`Name` = Warehouse.`Name`)
	where (Warehouse.WarehouseID is null);
end$$
delimiter ;

