select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'text' as component,
	(select title from assistants where id = $id) as contents;

select
	'button' as component;
select
	'/ui/views/assistants.edit?id=' || $id     as link,
	'azure' as outline,
	'Edit'  as title,
	'edit'  as icon;
select
	'/ui/views/assistants.edit?id=' || $id      as link,
	'danger' as outline,
	'Delete' as title,
	'trash'  as icon;