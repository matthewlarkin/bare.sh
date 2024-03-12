select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'title' as component,
	'Assistants' as contents;

select 'card' as component,
	3 as columns;

	select
		name as title,
		'/ui/views/assistants.show?id=' || id as link
		from assistants;