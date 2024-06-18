use eStore;

drop procedure if exists usp_CreateNewPickUpPoint;

delimiter $$
create procedure usp_CreateNewPickUpPoint(in InJson json)
proc_body:
begin
    -- describe reaction on error
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;
    -- create new PickUpPoint
    insert into PickUpPoint (`Name`, Address, WorkingTime)
    with cte_JsonData (`Name`, Address, WorkingTime) as
    (
        select js.`Name`,
               js.Address,
               js.WorkingTime
        from JSON_TABLE(InJson, '$' columns 
                                (
                                    `Name`          nvarchar(60)   path N'$.PickUpPoint.Name',
                                    Address         nvarchar(255)  path N'$.PickUpPoint.Address',
                                    WorkingTime     nvarchar(255)  path N'$.PickUpPoint.WorkingTime'
                                ) 
                        ) js
    )
    select cte_JsonData.`Name`,
           cte_JsonData.Address,
           cte_JsonData.WorkingTime
    from cte_JsonData left outer join
         PickUpPoint on (cte_JsonData.`Name` = PickUpPoint.`Name`)
	where (PickUpPoint.PickUpPointID is null);
end$$
delimiter ;

