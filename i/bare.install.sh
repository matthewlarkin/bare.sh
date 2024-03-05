#!/usr/bin/env bash

# Convert variables to a regular array
declare -a env=(
	"BARE_OS"
	"BARE_ENCRYPTION_KEY"
	"BARE_GIT_NAME"
	"BARE_GIT_EMAIL"
	"BARE_OPENAI_KEY"
	"BARE_POSTMARK_TOKEN"
	"BARE_STRIPE_KEY"
	"BARE_DAILY_TOKEN"
	"BARE_NOTES_DIR"
)

declare -a core_deps=(
	"npm"
	"bash"
	"git"
	"curl"
	"git"
	"jq"
	"glow"
)

declare -a rec_deps=(
)

declare -a misc_deps=(
	"ddgr"
	"sumy"
	"xidel"
)

# check if all the environment variables are set and 