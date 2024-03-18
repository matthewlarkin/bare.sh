create table "tags" (
	"id" integer primary key autoincrement,
	"title" text not null,
	"created_at" datetime not null default current_timestamp,
	"updated_at" datetime not null default current_timestamp
);

create table "assistants" (
	"id" text primary key unique not null,
	"title" text not null,
	"model" text not null,
	"tools" text not null,
	"instructions" text not null,
	"created_at" datetime not null default current_timestamp,
	"updated_at" datetime not null default current_timestamp
);

create table "assistant_tags" (
	"assistant_id" text not null references "assistants" ("id"),
	"tag_id" integer not null references "tags" ("id"),
	primary key ("assistant_id", "tag_id")
);

create table "threads" (
	"id" text primary key unique not null,
	"title" text not null,
	"created_at" datetime not null default current_timestamp,
	"updated_at" datetime not null default current_timestamp
);

create table "thread_messages" (
	"id" integer primary key autoincrement,
	"thread_id" integer not null references "threads" ("id"),
	"name" text not null,
	"content" text not null,
	"created_at" datetime not null default current_timestamp,
	"updated_at" datetime not null default current_timestamp
);

create table "documents" (
	"id" integer primary key autoincrement,
	"title" text not null,
	"content" text not null,
	"created_at" datetime not null default current_timestamp,
	"updated_at" datetime not null default current_timestamp
);

create table "document_tags" (
	"document_id" integer not null references "documents" ("id"),
	"tag_id" integer not null references "tags" ("id"),
	primary key ("document_id", "tag_id")
);

create table "scripts" (
	"id" integer primary key autoincrement,
	"title" text not null,
	"content" text not null,
	"created_at" datetime not null default current_timestamp,
	"updated_at" datetime not null default current_timestamp
);