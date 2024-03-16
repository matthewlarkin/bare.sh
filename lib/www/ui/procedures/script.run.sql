set content = :content;
set script = sqlpage.exec('./bare', 'relay',
	'-c', $content,
	'-o', 'scripts/test.bare');

set run = sqlpage.exec('./bare', 'script', 'run', 'test.bare');

select 'alert' as component,
	'Success!' as title,
	true as dismissible,
	'check' as icon,
	'green' as color;

select 'code' as component;
	select
		'plaintext' as language,
		$run as contents;