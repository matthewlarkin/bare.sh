select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 
	'breadcrumb' as component;

	select 
		'Home' as title,
		'/'    as link;
	select 
		'Assistants' as title,
		'/assistants.sql' as link;
	select 
		'/ui/views/assistant.show.sql?id=' || id as link,
		title as title from assistants where id = $id;
	select
		'✍️' as title,
		true as active;



select 'form' as component,
	'/ui/procedures/assistant.edit.sql?id=' || $id as action,
	'POST' as method;

	select
		'title' as name,
		'Name' as label,
		name as value from assistants where id = $id;
	select
		'content' as name,
		'Instructions' as label,
		'textarea' as type,
		content as value from assistants where id = $id;