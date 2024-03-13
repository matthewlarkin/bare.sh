delete from assistants where id = $id;

select 'redirect' as component,
	'/assistants.sql?message=deleted' as link;