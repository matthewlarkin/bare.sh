update documents set title = :title, content = :content where id = $id;

select 'redirect' as component,
	'/ui/views/document.show.sql?id=' || $id || '&message=updated' as link;