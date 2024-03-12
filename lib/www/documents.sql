select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'title' as component,
	'Documents' as contents,
	true as center;

set home = sqlpage.exec('./bare', 'notes', 'list', '-J');
set research = sqlpage.exec('./bare', 'notes', 'list', '-N', 'research', '-J');

-- documents is a json array: id:, filename:, notebook:

select 'title' as component,
	'Home' as contents;

select 'card' as component,
	3 as columns;
select
	json_extract($home, '$[0].filename') as title,
	'/documents.sql?id=' || json_extract($home, '$[0].notebook') || ':' || json_extract($home, '$[0].id') as link;

select 'title' as component,
	'Research' as contents;

select 'card' as component,
	3 as columns;
select
	json_extract($research, '$[0].filename') as title,
	'/documents.sql?id=' || json_extract($research, '$[0].notebook') || ':' || json_extract($research, '$[0].id') as link;

