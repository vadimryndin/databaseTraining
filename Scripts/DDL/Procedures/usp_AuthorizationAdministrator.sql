use eStore;

drop procedure if exists usp_AuthorizationAdministrator;

delimiter $$
create procedure usp_AuthorizationAdministrator(in InJson json)
proc_body:
begin
    -- describe reaction on error
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;
    -- create temporary table for json data    
    drop table if exists tempJson;
    create temporary table tempJson
    (
        Login nvarchar(60)
    );
    -- insert data from json in tempJson table
    insert into tempJson (Login)
    select js.Login
    from JSON_TABLE(InJson, '$' columns 
                                (
                                   Login nvarchar(60) path N'$.Administrator.Login'
                                )
                   ) js;
     -- do administrator exists?
     if not exists (select Administrator.AdministratorID
                    from tempJson inner join 
                         Administrator on (tempJson.Login = Administrator.Login))
     then
        select 'Error: no such administrator.';
        leave proc_body;
     end if;
     -- no other operations required at this iteration of project
end$$
delimiter ;

