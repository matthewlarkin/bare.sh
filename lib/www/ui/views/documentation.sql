select 'dynamic' as component, sqlpage.read_file_as_text('assets/data/shell.json') as properties;

select 'title' as component,
	'The bare essentials' as contents;

select 'text' as component,
	'Learn the basics of the bare ecosystem.' as contents;

select 'card' as component;

	select 'What is bare?' as title,
		'Get a lay of the bare land' as description_md,
		'green' as color,
		'star' as icon;	

	select 'Bare scripting' as title,
		'Learn how to **automate tasks** with bare scripts' as description_md,
		'green' as color,
		'code' as icon;

	select 'GitHub' as title,
		'Bare is open source on GitHub!' as description_md,
		'green' as color,
		'https://github.com/matthewlarkin/bare.sh' as link,
		'brand-github' as icon;

select 'title' as component,
	'Bare ingredients' as contents;

select 'text' as component,
	'Learn how to use the bare scopes, solo or in concert.' as contents;

select 'card' as component;

	select 'Notes' as title,
		'Keep track of notes, projects, and tasks' as description,
		'note' as icon;

	select 'OpenAI' as title,
		'Interact with AI models' as description,
		'code' as icon;

	select 'Email' as title,
		'Send and receive emails' as description,
		'mail-forward' as icon;

	select 'Weather' as title,
		'Get the weather' as description,
		'sun' as icon;

	select 'Stripe' as title,
		'Payments and invoicing' as description,
		'credit-card' as icon;

	select 'Research' as title,
		'Do some AI powered auto-research' as description,
		'book' as icon;

	select 'Daily' as title,
		'Video and audio conferencing' as description,
		'video' as icon;

	select 'FFmpeg' as title,
		'Convert and edit multimedia' as description,
		'photo-video' as icon;

	select 'Geo' as title,
		'Get latitudes and longitudes' as description,
		'map-2' as icon;

	select 'Import' as title,
		'Import data from various sources' as description,
		'download' as icon;

	select 'Export' as title,
		'Export data to various sources' as description,
		'upload' as icon;

	select 'Cryptography' as title,
		'Encrypt and decrypt data' as description,
		'lock' as icon;

	select 'Codec' as title,
		'Encode and decode data' as description,
		'code' as icon;

	select 'Random' as title,
		'Generate random text and numbers' as description,
		'grain' as icon;

	select 'Relay' as title,
		'Relay information' as description,
		'arrow-narrow-right' as icon;

select 'title' as component,
	'Sandbox' as contents;