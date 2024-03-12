update assistants set name = $name, content = $content where id = $id;

select 'redirect' as component,
	'/ui/views/assistants.show.sql?id=' || $id || '&message=Assistant+updated' as link;