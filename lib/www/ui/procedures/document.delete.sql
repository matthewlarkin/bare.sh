delete from document where id = $id;

select 'redirect' as component,
	'/document.sql?message=deleted' as link;