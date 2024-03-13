set assistant_id = sqlpage.exec('./bare', 'openai', 'assistants.create', '-n', :title, '-i', :content);

insert into assistants (id, title, content) values ($assistant_id, :title, :content);