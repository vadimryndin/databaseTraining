use estore;

drop procedure if exists usp_ClientOrdersStatusReport;

delimiter $$

create procedure usp_ClientOrdersStatusReport(in InJson json)
proc_body:
begin
    -- declare local variables
    declare var_StartDate date;
    declare var_EndDate date;
    declare var_SortingMode int;
    declare var_PhoneNumber varchar(20);
    declare var_WhereSectionExists tinyint default 0;
    declare var_ErrorMsg varchar(255);

    -- describe reaction on error
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;

    -- create temporary table for json data
    drop temporary table if exists tempJson;

    create temporary table tempJson (
        Login          varchar(20),
        PhoneNumber    varchar(20),
        StartDate      date,
        EndDate        date,
        SortingMode    int
    );

    -- insert data from json in tempJson table
    insert into tempJson (Login, PhoneNumber, StartDate, EndDate, SortingMode)
    select js.Login,
           js.PhoneNumber,
           js.StartDate,
           js.EndDate,
           js.SortingMode
    from JSON_TABLE(InJson, '$' columns (
                                    Login          varchar(20) path N'$.Administrator.Login',
                                    PhoneNumber    varchar(20) path N'$.PhoneNumber',
                                    StartDate      date        path N'$.Period.StartDate',
                                    EndDate        date        path N'$.Period.EndDate',
                                    SortingMode    int         path N'$.SortingMode'
    )) AS js;

    -- check process initiator
    if not exists (select Administrator.AdministratorID
                   from tempJson inner join
                        Administrator on (tempJson.Login = Administrator.Login))
    then
        select 'Error: process initiator wrong!';
        leave proc_body;
    end if;
    
    -- check if JSON data is correct
    if not exists (select 1 from tempJson where PhoneNumber is not null) 
    then
        select 'Error: Invalid JSON data.';
        leave proc_body;
    end if;

    -- prepare the main query
    set @ResultQuery := N'
        select o.Code AS OrderCode, o.FinalCost, s.Name AS Status, o.CreationDateTime AS Date 
        from `Order` o 
        inner join OrderStatus s ON o.StatusID = s.OrderStatusID 
        inner join Client c ON o.ClientID = c.ClientID';

    -- add filter for client's phone number
    set var_PhoneNumber := (select PhoneNumber from tempJson limit 1);
    if var_PhoneNumber is not null then
        set @ResultQuery := CONCAT(@ResultQuery, ' WHERE c.PhoneNumber = ''', var_PhoneNumber, '''');
        set var_WhereSectionExists := 1;
    end if;

    -- add filter for the date range
    set var_StartDate := (select StartDate from tempJson limit 1);
    set var_EndDate := (select EndDate from tempJson limit 1);
    if var_StartDate is not null then
        if var_WhereSectionExists = 0 then
            set @ResultQuery := CONCAT(@ResultQuery, ' WHERE');
            set var_WhereSectionExists := 1;
        else
            set @ResultQuery := CONCAT(@ResultQuery, ' AND');
        end if;
        set @ResultQuery := CONCAT(@ResultQuery, ' DATE(o.CreationDateTime) >= ''', var_StartDate, '''');
    end if;
    if var_EndDate is not null then
        if var_WhereSectionExists = 0 then
            set @ResultQuery := CONCAT(@ResultQuery, ' WHERE');
            set var_WhereSectionExists := 1;
        else
            set @ResultQuery := CONCAT(@ResultQuery, ' AND');
        end if;
        set @ResultQuery := CONCAT(@ResultQuery, ' DATE(o.CreationDateTime) <= ''', var_EndDate, '''');
    end if;

    -- add sorting mode
    set var_SortingMode := (select SortingMode from tempJson limit 1);
    if var_SortingMode = 1 then
        set @ResultQuery := CONCAT(@ResultQuery, ' ORDER BY o.CreationDateTime ASC');
    elseif var_SortingMode = 2 then
        set @ResultQuery := CONCAT(@ResultQuery, ' ORDER BY o.Code ASC');
    end if;

    -- execute result query
    prepare stmt from @ResultQuery;
    execute stmt;
    deallocate prepare stmt;

end$$

delimiter ;
