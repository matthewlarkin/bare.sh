select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'title' as component,
	'Create Document' as contents,
	true as center;

select 'breadcrumb' as component;

	select 
		'Home' as title,
		'/'    as link;
	select 
		'Documents' as title,
		'/documents.sql' as link;
	select
		true as active,
		'new' as title;

select 'form' as component,
	'/ui/procedures/documents.create.sql' as action,
	'POST' as method;

	select
		'title' as name,
		'Name' as label,
		'' as value;
	select
		'content' as name,
		'Content' as label,
		'textarea' as type,
		'' as value;