select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'title' as component,
	'Create Assistant' as contents,
	true as center;

select 'breadcrumb' as component;

	select 
		'Home' as title,
		'/'    as link;
	select 
		'Assistants' as title,
		'/assistants.sql' as link;
	select
		true as active,
		'create' as title;

select 'form' as component,
	'/ui/procedures/assistants.create.sql' as action,
	'POST' as method;

	select
		'title' as name,
		'Name' as label,
		'text' as type;
	select
		'content' as name,
		'Content' as label,
		'textarea' as type;

select 'button' as component;
	select
		'/assistants.sql' as link,
		'azure' as outline,
		'Cancel' as title,
		'arrow-left' as icon;