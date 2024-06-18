use eStore;

drop procedure if exists usp_CreateSystemRoles;

delimiter $$
create procedure usp_CreateSystemRoles(in InJson json)
proc_body:
begin
    -- describe reaction on error
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;
    -- create system roles (addition roles to existing ones)
    insert into SystemRole (`Name`)
    with cte_JsonData (`Name`) as
    (
        select js.`Name`
        from JSON_TABLE(InJson, '$.SystemRole[*]' columns 
                                (
                                    `Name` nvarchar(30) path N'$.Name'
                                ) 
                        ) js
    )
    select cte_JsonData.`Name`
    from cte_JsonData left outer join
         SystemRole on (cte_JsonData.`Name` = SystemRole.`Name`)
    where (SystemRole.SystemRoleID is null);
end$$
delimiter ;

