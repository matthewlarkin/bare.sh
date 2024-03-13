insert into documents (title, content) values (:title, :content);

select 'redirect' as component,
	'/ui/views/document.show.sql?id=' || last_insert_rowid() as link;