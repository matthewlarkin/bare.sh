set response = sqlpage.exec('./bare', 'openai', 'chat',
	'-m', :content,
	'-a', :assistant_id
);

select 'text' as component,
	$response as contents_md;