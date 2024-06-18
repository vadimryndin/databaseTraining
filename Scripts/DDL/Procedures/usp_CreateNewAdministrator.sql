use eStore;

drop procedure if exists usp_CreateNewAdministrator;

delimiter $$
create procedure usp_CreateNewAdministrator(in InJson json)
proc_body:
begin
    -- describe reaction on error
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;
    -- create new administrator
    insert into Administrator (Login, PasswordHash)
    with cte_JsonData (Login, PasswordHashMD5) as
    (
        select js.Login,
               js.PasswordHashMD5
        from JSON_TABLE(InJson, '$' columns 
                                (
                                    Login           varchar(20) path N'$.Administrator.Login',
                                    PasswordHashMD5 char(32)    path N'$.Administrator.PasswordHashMD5'
                                ) 
                        ) js
    )
    select cte_JsonData.Login,
           cte_JsonData.PasswordHashMD5
    from cte_JsonData;
end$$
delimiter ;

