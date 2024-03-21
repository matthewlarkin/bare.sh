select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

set script = "# Sandbox script\n" || :script;

set file = sqlpage.exec('./bare', 'relay',
	'-c', $script,
	'-o', 'scripts/sandbox.bare'
);

set response = sqlpage.exec('./bare', 'interpret', 'sandbox.bare');

set clear = sqlpage.exec('./bare', 'relay',
	'-c', '# Sandbox script',
	'-o', 'scripts/sandbox.bare'
);

select 'title' as component,
	'Bare shell' as contents;

select 'text' as component,
	'A *shell* is a simple interface to write and execute commands. Think of it as the *shell* of a nut that sits on top of the core fruit of the system.' as contents_md;

select 'form' as component,
	'POST' as method,
	'/shell.sql' as action,
	'Execute' as validate,
	'dark' as validate_color;

	select
		'script' as name,
		'Bare script' as label,
		:script as value,
		'textarea' as type;

select 'title' as component,
	'Results' as contents;

select 'code' as component where $response is not null;

select $response as contents,
	'plaintext' as language where $response is not null;