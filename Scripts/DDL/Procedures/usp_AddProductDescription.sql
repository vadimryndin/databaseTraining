use estore;

drop procedure if exists usp_AddProductDescription;

delimiter $$

create procedure usp_AddProductDescription(in InJson json)
begin

    declare v_ProductID SMALLINT;

    -- error handling
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;

    drop temporary table if exists tempJson;

    -- Create temporary table to hold the parsed JSON data
    create temporary table tempJson (
        `Name`              nvarchar(120),
        `Code`              char(32),
        CatalogSection      nvarchar(60),
        Price               nvarchar(60),
        Weight              nvarchar(60),
        Brand               nvarchar(20),
        State               nvarchar(60),
        Color               nvarchar(60),
        Size                nvarchar(60)
    );

     -- Insert JSON data into the temporary table
    insert into tempJson (`Name`, `Code`, CatalogSection, Price, Weight, Brand, State, Color, Size)
    select 
        js.`Name`,
        js.`Code`,
        js.CatalogSection,
        js.Price,
        js.Weight,
        js.Brand,
        js.State,
        JSON_UNQUOTE(JSON_EXTRACT(InJson, '$.Product.Characteristics[0].value')) as Color,
        JSON_UNQUOTE(JSON_EXTRACT(InJson, '$.Product.Characteristics[1].value')) as Size
    from JSON_TABLE(InJson, '$' COLUMNS (
                                        `Name`          nvarchar(120) path '$.Product.Name',
                                        `Code`          char(32)      path '$.Product.Code',
                                        CatalogSection  nvarchar(60)  path '$.CatalogSection.Name',
                                        Price           nvarchar(60)  path '$.Product.Price',
                                        Weight          nvarchar(60)  path '$.Product.Weight',
                                        Brand           nvarchar(20)  path '$.Brand.Name',
                                        State           nvarchar(60)  path '$.State.Name'
    )) as js;

    -- Insert into Product table and retrieve ProductID
    insert into Product (`Name`, `Code`, CatalogSectionID, Price, Weight, BrandID, StateID, ColorID, SizeID)
    select 
        t.`Name`,
        t.`Code`,
        cs.CatalogSectionID,
        t.Price,
        t.Weight,
        b.BrandID,
        s.StateID,
        c.ColorID,
        sz.SizeID
    from tempJson t
    join CatalogSection cs on cs.Name = t.CatalogSection
    join Brand b on b.Name = t.Brand
    join State s on s.Name = t.State
    left join Color c on c.Name = t.Color
    left join Size sz on sz.Name = t.Size;

    commit;

end$$

delimiter ;
