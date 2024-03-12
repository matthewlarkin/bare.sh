select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 
'breadcrumb' as component;

	select 
		'Home' as title,
		'/'    as link;
	select 
		'Assistants' as title,
		true as active;

select 'title' as component,
	'Assistants' as contents;

select 'card' as component,
	3 as columns;

	select
		name as title,
		'/ui/views/assistants.show.sql?id=' || id as link
		from assistants;