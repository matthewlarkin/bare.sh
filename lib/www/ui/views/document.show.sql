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
		true as active,
		title as title from documents where id = $id;

select 'title' as component,
	title as contents
	from documents where id = $id;

select 'text' as component,
	content as contents_md
	from documents where id = $id;


select 'button' as component;

select
	'/ui/views/document.edit.sql?id=' || $id     as link,
	'azure' as outline,
	'Edit'  as title,
	'edit'  as icon;

select
	'/ui/views/document.delete.sql?id=' || $id      as link,
	'danger' as outline,
	'Delete' as title,
	'trash'  as icon;


select 'alert' as component,
	'Updated!' as title,
	true as dismissible,
	'check' as icon,
	'green' as color
	where $message = 'updated';