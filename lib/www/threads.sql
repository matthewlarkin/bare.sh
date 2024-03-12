select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'title' as component,
	'Threads' as contents,
	true as center;

set threads = sqlpage.exec('./bare', 'notes', 'list', '-J');