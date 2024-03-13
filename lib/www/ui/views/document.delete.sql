select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select
	'breadcrumb' as component;

	select
		'Home' as title,
		'/'    as link;
	select
		'Documents' as title,
		'/documents.sql' as link;
	select
		'/ui/views/document.show.sql?id=' || id as link,
		title as title from documents where id = $id;
	select
		'Delete' as title,
		true as active;

select 'form' as component,
	'/ui/procedures/document.delete.sql?id=' || $id as action,
	'POST' as method;

	select
		'hidden' as type,
		'id' as name,
		id as value from documents where id = $id;

select 'button' as component;

	select
		'/ui/procedures/document.delete.sql?id=' || $id as link,
		'danger' as outline,
		'Delete' as title,
		'trash' as icon;

	select
		'/documents.sql' as link,
		'azure' as outline,
		'Cancel' as title,
		'arrow-left' as icon;