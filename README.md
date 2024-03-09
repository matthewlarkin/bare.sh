# bare.sh

`bare.sh` is a collection of bare bones bash scripts for streamlining common tasks such as:

- API calls (*OpenAI, Stripe, Postmark, etc*)
- video and audio processing (`ffmpeg`)
- document management (`nb`)
- *and much more!*

Simplified API interfaces. Minimalist JSON responses. Few dependencies. Unreasonably easy.

**Jump to:**
- [Why?](#why)
- [Dependencies](#dependencies)
- [Overview](#overview)
- [Quick Samples](#quick-samples)
- [Documentation](#documentation)
- [Installation](#installation)
- [Interactive Samples](#interactive-samples)

---

## Why?
"Why do this?", you may ask. Why not just use the official libraries? And why bash? Why not python?

1. **Simplicity**: This system is straightforward, focusing on easy-to-understand, functional commands.
2. **Ubiquity**: Bash is fast and widely available, making this system portable and the commands composable.
3. **Expressivity**: `bare.sh` commands are more memorable, designed to be *spoken*, to accomplish the 80% of your actual needs.

```bash
# 😬 Standard methods can be difficult to call, and their requests can be complex to parse.

echo $(LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16)
# >> Qq3Sv8yW5yMCAlq9

echo $(LC_ALL=C tr -dc '0-9' < /dev/urandom | head -c 10)
# >> 6306425682

curl -X POST -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" -d '{"model": "gpt-3.5-turbo", "messages": [{"role": "system", "content": "You are a chef"}, {"role": "user", "content": "Are you a chef?"}]}' https://api.openai.com/v1/chat/completions | jq
# >> {"id":"chatcmpl-8wYMvPDyn3O3VBvt0GDuP7mgMhq8W","object":"chat.completion","created":1708965829,"model":"gpt-3.5-turbo-0125","choices":[{"index":0,"message":{"role":"assistant","content":"Yes, I am a virtual chef ready to help you with any cooking-related questions or recipe ideas!"},"logprobs":null,"finish_reason":"stop"}],"usage":{"prompt_tokens":20,"completion_tokens":20,"total_tokens":40},"system_fingerprint":"fp_86156a94a0"}


# - - - 🌿 - - - 🌿 - - - 🌿 - - -


# 🤩 using bare.sh

bare random string
# >> CYtxhPr55ILYwQ9c

bare random number 10
# >> 2348063108

bare openai chat -m "Are you a chef?" -a "You are a chef"
# >> Yes, I am a chef! How can I help you today?
```

**Notice**: *You don't have to know bash to use bare.sh*. Just like any other library, you just invoke the commands and pass in the necessary arguments.

> **Note/warning**: This is a work in progress. Some features may not be fully implemented or may change **dramatically** in these early days. If you have any questions or suggestions, feel free to open an issue or pull request!

---

## Dependencies
This system is intended to be used on a unix-like OS (Linux, MacOS, WSL, etc). It is written in bash and uses a few common utilities such as `curl`, `jq`, `ffmpeg`, and some nice-to-haves like `nb`. You'll want to have those installed, but the scripts will let you know if you don't.

These are all available in most package managers.

---

## Overview
At it's root, `bare.sh` is a collection of unix-like directories (`/b`, `/i`, `/lib`, `/tmp`, and `/var`) each containing bash scripts and programs for specific tasks.

Most of these scripts are small in scope, take simple input, and provide simple plaintext or JSON output. This allows us to chain commands together to accomplish more complex tasks.

---

## Quick Samples
Let's get something going. To give you an idea of how you can use the system, here are a few quick examples.
```bash
# OpenAI
openai chat "Hello there!"

# => General Kenobi! You are a bold one.

b/openai assistants.create \
    -n "Copy editor" \
    -i "You are a copy editor. You take any content given \
    to you and return the edited version, followed with \
    structured constructive critiques." \
    -t "code_interpreter|retrieval" \

# => asst_LXpGvduRLm6muXHBC3i1PH3s

# =============

# Video
b/ffmpeg video.360 -f my_video.mp4 -o my_video.360.mp4

# => { "360p_file" : "my_video.360.mp4" }
```

---

## Documentation
Bare is split into several *scopes* (`openai`, `ffmpeg`, `random`, etc). We can document the scopes using the `doc` scope.
```bash
# document the OpenAI scope
bare doc openai

# document the OpenAI chat command
bare doc openai chat
---

## Installation
To install, simply clone the repo. You can set ./bare as an alias in your shell for easy access.
```bash
# Clone the repo and navigate to into it
git clone https://github.com/matthewlarkin/bare.sh && cd bare.sh

# Set the bare command as an alias
echo "alias bare=$PWD/bare" >> ~/.bashrc # or ~/.zshrc, etc

# Setup your environment variables in the lib/.env file
vim lib/.env
```