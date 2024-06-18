use eStore;

drop procedure if exists usp_CreateNewCatalogSection;

delimiter $$
create procedure usp_CreateNewCatalogSection(in InJson json)
proc_body:
begin
    -- describe reaction on error
    declare exit handler for sqlexception
    begin
        get diagnostics @p1 = number;
        get diagnostics condition @p1 @p2 = message_text;
        select @p1, @p2;
    end;
    -- create new CatalogSection
    insert into CatalogSection (`Name`, ParentSectionID)
    with cte_JsonData (`Name`, ParentSectionName) as
    (
        select js.`Name`,
               js.ParentSectionName
        from JSON_TABLE(InJson, '$' columns 
                                (
                                    `Name`                 nvarchar(60)  path N'$.CatalogSection.Name',
                                    ParentSectionName      nvarchar(60)  path N'$.ParentCatalogSection.Name'
                                ) 
                        ) js
    )
    select cte_JsonData.`Name`,
           COALESCE(parent.CatalogSectionID, NULL) as ParentSectionID
    from cte_JsonData
    left join (CatalogSection parent on cte_JsonData.ParentSectionName = parent.`Name`);
end$$
delimiter ;

