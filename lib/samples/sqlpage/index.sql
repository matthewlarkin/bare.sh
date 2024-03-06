select 'shell' as component,
	'bare.sh' as 'title';

select 'form' as component,
	'Write your own bare script' as title,
	'post' as method,
	'/' as action;

select 'name' as name,
	'Name' as label;

select 'script' as name,
	'textarea' as type,
	'bare script' as label;

set name = :name || '.bare';
set script_id = sqlpage.exec('./bare', 'notes', 'create',
	'-T', :name,
	'-f', $name,
	'-C', :script,
	'-N', 'scripts'
);

set response = sqlpage.exec('./bare', 'interpret', $name);

select 'text' as component,
	$response as contents;