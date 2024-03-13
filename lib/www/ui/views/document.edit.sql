select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'title' as component,
	'Edit Document' as contents,
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
		'edit' as title;

select 'form' as component,
	'/ui/procedures/document.edit.sql?id=' || $id as action,
	'POST' as method;

	select
		'title' as name,
		'Name' as label,
		title as value from documents where id = $id;
	select
		'content' as name,
		'Content' as label,
		'textarea' as type,
		content as value from documents where id = $id;