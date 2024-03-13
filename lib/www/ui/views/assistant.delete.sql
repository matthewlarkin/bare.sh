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
		'Delete' as title,
		true as active;

set title = (select title from assistants where id = $id);

select 'text' as component,
	'Are you sure you want to delete the assistant "**' || $title || '**"?' as contents_md;

select 'button' as component;

	select
		'/assistants.sql' as link,
		'azure' as outline,
		'Cancel' as title,
		'arrow-left' as icon;

	select
		'/ui/procedures/assistant.delete.sql?id=' || $id as link,
		'danger' as outline,
		'Yes, delete' as title,
		'trash' as icon;