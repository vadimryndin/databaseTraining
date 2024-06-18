use eStore;

drop procedure if exists usp_AuthorizationEmployee;

delimiter $$
create procedure usp_AuthorizationEmployee(in InJson json)
proc_body:
begin
    -- describe reaction on error
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;
    -- save authorization data to log
    insert into AuthorizationEmployeeLog (EmployeeID, AuthorizationDateTime)
    with cte_JsonData (Login, AuthorizationDateTime) as
    (
        select js.Login,
               js.AuthorizationDateTime
        from JSON_TABLE(InJson, '$' columns 
                                (
                                    Login                 nvarchar(60) path N'$.Employee.Login',
                                    AuthorizationDateTime varchar(25)  path N'$.AuthorizationDateTime'
                                ) 
                       ) js
    )
    select Employee.EmployeeID,
           cte_JsonData.AuthorizationDateTime
    from cte_JsonData inner join
         Employee on (cte_JsonData.Login = Employee.Login);
end$$
delimiter ;

