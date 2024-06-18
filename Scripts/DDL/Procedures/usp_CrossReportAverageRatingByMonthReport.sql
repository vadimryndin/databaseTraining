use estore;

drop procedure if exists usp_CrossReportAverageRatingByMonthReport;

-- create parser procedure
delimiter $$
create procedure usp_CrossReportAverageRatingByMonthReport(in InJson json)
proc_body:
begin
    -- declare local variables
    declare var_StartDate date;
    declare var_FinishDate date;
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
        Login        varchar(20),
        ProductCode  char(32),
        `Month`      nvarchar(15),
        StartDate    date,
        FinishDate   date,
        ShowNullCols bool,
        ShowNullRows bool
    );
    -- insert data from json in tempJson table
    insert into tempJson (Login, ProductCode, `Month`, StartDate, FinishDate, ShowNullCols, ShowNullRows)
    select js.Login,
           js.ProductCode,
           js.`Month`,
           js.StartDate,
           js.FinishDate,
           js.ShowNullCols,
           js.ShowNullRows
    from JSON_TABLE(InJson, '$' columns 
                            (
                                Login        varchar(20)    path N'$.Administrator.Login',
                                StartDate    date           path N'$.Period.StartDate',
                                FinishDate   date           path N'$.Period.FinishDate',
                                ShowNullCols bool           path N'$.ShowNullCols',
                                ShowNullRows bool           path N'$.ShowNullRows',
                                nested path '$.ProductCode[*]' columns
                                (
                                    ProductCode char(32) path N'$.Name'
                                ),
                                nested path '$.Month[*]' columns
                                (
                                    `Month` nvarchar(15) path N'$.Name'
                                )
                            )
                   ) js;
    -- check json data if you need
    -- check process initiator
    if not exists (select Administrator.AdministratorID
                   from tempJson inner join
                        Administrator on (tempJson.Login = Administrator.Login))
    then
        select 'Error: process initiator wrong!';
        leave proc_body;
    end if;
    -- check period
    if exists (select tempJson.StartDate
               from tempJson 
               where ((tempJson.StartDate > tempJson.FinishDate) or
                      (tempJson.StartDate is null) or
                      (tempJson.FinishDate is null)))
    then
        select 'Error: period wrong!';
        leave proc_body;
    end if;
    -- prepare period variables
    set var_StartDate := (select distinct tempJson.StartDate from tempJson);
    set var_FinishDate := (select distinct tempJson.FinishDate from tempJson);
    -- prepare temporary table for job positions
    drop table if exists tempProductCode;
    create temporary table tempProductCode
    (
        `Name` nvarchar(60)
    );
    -- prepare temporary table for months
    drop table if exists tempMonth;
    create temporary table tempMonth
    (
        `Name` nvarchar(15)
    );
    -- create temporary table for raw data (it's data for objects connecting with used categouries without grouping and agregating) for analytic
    drop table if exists tempRawData;
    create temporary table tempRawData
    (
        ProductCode nvarchar(60),
        `Month`     nvarchar(15),
        Rating      decimal(5,2)
    );
    -- form set of Product code
    if exists (select tempJson.ProductCode
                from tempJson inner join 
                    Product on (tempJson.ProductCode = Product.`Code`))
    then
        -- add unique job positions from tempJson table but existing in database
        insert into tempProductCode (`Name`)
        select distinct tempJson.ProductCode
        from tempJson inner join 
            Product on (tempJson.ProductCode = Product.`Code`);
    else
        -- add all job positions from database    
        insert into tempProductCode (`Name`)
        select Product.`Code`
        from Product;
    end if;
    -- form set of days of week
    if exists (select tempJson.`Month`
               from tempJson
               where tempJson.`Month` is not null)
    then
        -- add unique not null days of week from tempJson table
        insert into tempMonth (`Name`)
        select distinct tempJson.`Month`
        from tempJson
        where tempJson.`Month` is not null;
    else
        -- add all days of week
        insert into tempMonth (`Name`)
        values ('January'), ('February'), ('March'), ('April'), ('May'), ('June'), ('July'), ('August'), ('September'), 
                ('October'), ('November'), ('December');
    end if;
    -- prepare raw data
    if 1 = (select distinct tempJson.ShowNullRows from tempJson)
    then
        -- insert data for all Product codes from tempProductCode table
        insert into tempRawData (ProductCode, `Month`, Rating)
        select tempProductCode.`Name`,
               DATE_FORMAT(pr.CreationDateTime, '%M') AS `Month`,
               r.Name AS Rating
        from tempProductCode
        left join Product p ON tempProductCode.`Name` = p.Code
        left join ProductReview pr ON p.ProductID = pr.ProductID
        left join Rating r ON pr.RatingID = r.RatingID
        left join tempMonth ON tempMonth.`Name` = DATE_FORMAT(pr.CreationDateTime, '%M')
        where ((DATE(pr.CreationDateTime) >= var_StartDate) and
                (DATE(pr.CreationDateTime) <= var_FinishDate)) or
               pr.CreationDateTime is null;
    else
        -- insert data only for used Product codes
        insert into tempRawData (ProductCode, `Month`)
        select tempProductCode.`Name`,
               DATE_FORMAT(pr.CreationDateTime, '%M') AS `Month`,
               r.Name AS Rating
        FROM tempProductCode
        inner join Product p ON tempProductCode.`Name` = p.Code
        inner join ProductReview pr ON p.ProductID = pr.ProductID
        inner join Rating r ON pr.RatingID = r.RatingID
        inner join tempMonth ON tempMonth.`Name` = DATE_FORMAT(pr.CreationDateTime, '%M')
        where (DATE(pr.CreationDateTime) >= var_StartDate) and
               (DATE(pr.CreationDateTime) <= var_FinishDate);
    end if;
    -- prepare main part of result transpose analytic query
    set @ResultQuery = N'
            select tempRawData.ProductCode as ''Product code'',
                {ResultSubquery}
            from tempRawData 
            group by tempRawData.ProductCode;';
    -- prepare subquery parts 
    if 1 = (select distinct tempJson.ShowNullCols from tempJson)
    then
        -- prepare columns with all months
        select GROUP_CONCAT(CONCAT('AVG(IF(tempRawData.Month = N''',
                                    tempMonth.`Name`,
                                    ''', tempRawData.Rating, NULL)) AS ''',
                                    tempMonth.`Name`,
                                    ''''))
        into @ResultSubquery
        from tempMonth;
    else
        -- prepare columns with only used months
        select GROUP_CONCAT(CONCAT('AVG(IF(tempRawData.Month = N''',
                                    tempMonth.`Name`,
                                    ''', tempRawData.Rating, NULL)) AS ''',
                                    tempMonth.`Name`,
                                    ''''))
        into @ResultSubquery
        from tempMonth
        where tempMonth.`Name` in (select distinct tempRawData.Month from tempRawData);
    end if;
    -- add subqueries for result
    set @ResultQuery := replace(@ResultQuery, N'{ResultSubquery}', @ResultSubquery);
    -- execute result query
    prepare stmt from @ResultQuery;
    execute stmt;
    deallocate prepare stmt;
end$$
delimiter ;


