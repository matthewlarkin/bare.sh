select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'title' as component,
	'Assistants' as contents,
	true as center;

select 'breadcrumb' as component;

	select 
		'Home' as title,
		'/'    as link;
	select 
		'Assistants' as title,
		true as active;

select 'card' as component,
	3 as columns;

	select
		title as title,
		'/ui/views/assistant.show.sql?id=' || id as link
		from assistants;

select 'button' as component;

	select
		'/ui/views/assistants.create.sql' as link,
		'azure' as outline,
		'Create' as title,
		'plus' as icon;

select 'alert' as component,
	'Created!' as title,
	true as dismissible,
	'check' as icon,
	'green' as color
	where $message = 'created';

select 'alert' as component,
	'Deleted!' as title,
	true as dismissible,
	'trash' as icon,
	'green' as color
	where $message = 'deleted';