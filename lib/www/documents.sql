select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'title' as component,
	'Documents' as contents,
	true as center;

select 'breadcrumb' as component;

	select 
		'Home' as title,
		'/'    as link;
	select 
		'Documents' as title,
		true as active;

select 'button' as component;

	select 
		'/ui/views/documents.create.sql' as link,
		'azure' as outline,
		'Create' as title,
		'plus' as icon;

select 'card' as component,
	3 as columns;

	select 
		'/ui/views/document.show.sql?id=' || id as link,
		title as title,
		content as contents_md from documents;
