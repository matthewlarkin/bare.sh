set assistant_id = sqlpage.exec('./bare', 'openai', 'assistants.create', '-n', :title, '-i', :instructions);

update assistants set
	title = :title,
	instructions = :instructions,
	updated_at = current_timestamp
	where id = $assistant_id;