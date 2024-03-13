select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'card' as component,
	'Scripts' as title,
	3 as columns;

select 'form' as component,
	'Bare script' as title,
	'ui/procedures/script.run.sql' as action;

select
	'textarea' as type,
	'content' as name;

select 'text' as component,
	$results as contents where $results != '';