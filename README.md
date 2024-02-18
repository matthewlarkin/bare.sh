# bare.sh

`bare.sh` is a collection of bare bones shell scripts for simplifying various tasks such as API calls (*OpenAI, Stripe, Postmark, etc*), video and audio processing, and much more. The goal is to provide a simple and easy to use interface for developers to quickly get started with the 80% of use case they'll actually use and avoid the bloat of larger libraries.

Simplified API interfaces. Minimalist JSON responses. Few dependencies. Unreasonably easy.

**Jump to:**
- [Why?](#why)
- [Dependencies](#dependencies)
- [Overview](#overview)
- [Quick Samples](#quick-samples)
- [Documentation](#documentation)
- [Installation](#installation)

## Why?
"Why do this?", you may ask. Why not just use the official libraries or other popular libraries? And why bash? Why not write this in python?

1. **Simplicity**: Official libraries are often large and complex, with many features that you may never use. This system is designed to be simple and allow expressive chaining of commands that are functional in nature and easy to understand and change over time.
2. **Speed + Ubiquity**: Bash can be very fast, and it's already installed on most systems and is great for quick scripts and one-liners. This system is designed to be fast and easy to use anywhere there is a shell (a lot of places).
3. **Expressiveness**: `bare.sh` commands are designed to have a certain speakable quality to them. They are designed to be easy to remember and easy to use in a variety of contexts.

```bash
# 😬 standard way to generate random strings and numbers
openssl rand -base64 12
echo $(( $RANDOM % 100 ))

# 🤩 using bare.sh
bin/random string
bin/random number
```

```bash
# 😬 standard way to send a chat message to OpenAI
curl https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
        "model": "gpt-3.5-turbo",
        "messages": [
            {
                "role": "system",
                "content": "You are a chef"
            },
            {
                "role": "user",
                "content": "Are you a chef?"
            }
        ]
    }'
# => response: {
#     "id": "chatcmpl-xxxxxxxxxxxxxxxxxxxxxxxx",
#     "object": "chat.completion",
#     "created": 1708270909,
#     "model": "gpt-3.5-turbo-0125",
#     "choices": [
#         {
#             "index": 0,
#             "message": {
#                 "role": "assistant",
#                 "content": "Yes, I am a chef! How can I help you today?"
#             },
#             "logprobs": null,
#             "finish_reason": "stop"
#         }
#     ],
#     "usage": {
#         "prompt_tokens": 21,
#         "completion_tokens": 14,
#         "total_tokens": 35
#     },
#     "system_fingerprint": "fp_xxxxxxxxxx"
# }

# 🤩 using bare.sh
bin/openai chat -a "You are a chef" -m "Are you a chef?"

# => response: {"response":"Yes, I am a chef! How can I help you today?"}
```

**You don't have to know bash to use the system!** Just like any other library, you just invoke the commands and pass in the necessary arguments. The system is designed to be easy to use and easy to understand.

> **Note**: This is a work in progress. Some features may not be fully implemented or may change dramatically in these early days. If you have any questions or suggestions, feel free to open an issue or pull request!

## Dependencies
This system is intended to be used on a unix-like OS (Linux, MacOS, WSL, etc). It is written in bash and uses a few common utilities such as `curl`, `jq`, `ffmpeg`. You'll want to have those installed, but the scripts will let you know if you don't.

These are all available in most package managers.

## Overview
At it's root, `bare.sh` is a collection of unix-like directories (`/bin`, `/lib`, `/sh`, and `/tmp`) each containing bash scripts and programs for a specific task.

Most of these scripts are small in scope, take simple input, and provide simple JSON output. This allows us to chain commands together and use them in a variety of inanticipatable ways, especially when combined with other tools like `jq`.

## Quick Samples
Let's get something going. To give you an idea of how you can use the system, here are a few quick examples.
```bash
# OpenAI
bin/openai chat -m "Hello there!"

# => { "response" : "General Kenobi! You are a bold one." }

bin/openai assistants.create \
    -n "Suspicous Susan" \
    -i "You take the given input and question it. \
    You pick it apart and look for the pessimistic \
    perspective and outline it succinctly." \
    -t "code_interpreter|retrieval" \

# => { "assistant_id": "asst_LXpGvduRLm6muXHBC3i1PH3s", "tools": ["code_interpreter","retrieval"] }

# =============

# Video
bin/ffmpeg video.360 -f my_video.mp4 -o my_video.360.mp4

# => { "360p_file" : "my_video.360.mp4" }
```

## Documentation
The system is self-documenting. Learn more about a commands usage by running any command without arguments -- even `bin/usage`! (which is itself used to print usage information for the other commands 😄)
```bash
bin/openai

# - - -
#
# 📚 Usage: bin/openai [commands]
#
#   chat                          Send a message to an AI model
#   assistants.create             Create a new assistant
#   threads.create                Create a new thread
#   thread.messages.append        Append a message to a thread
#   thread.messages.list          List messages in a thread
#   thread.run                    Run an assistant on a thread
#   thread.run.poll               Poll the status of a thread run
#   files.upload                  Upload a file to the OpenAI API
#   files.list                    List files uploaded to the OpenAI API
#   file.delete                   Delete a file from the OpenAI API
#   images.create                 Generate images from a prompt
#   audio.create                  Generate audio from a text prompt
#   audio.transcribe              Transcribe an audio file
#
# - - -

bin/openai chat

# - - -
#
# 📚 Usage: bin/openai chat [options]
#
#   -m    * The message to send
#   -o      The model to use
#   -j      Return the response as a JSON object
#   -v      Return the response in verbose mode
#
# - - -
```
For subcommands, options are denoted:
- `*` -- *required*
- `~` -- *encouraged*
- `=` -- *conditionally required*

## Installation
To install, simply clone the repo and run commands from the root of repo.
```bash
# Clone the repo and navigate to into it
git clone https://github.com/matthewlarkin/bare.sh && cd bare.sh

# Set necessary keys as environment variables *
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxx"

bin/openai chat -m "Tell me if this worked."
```
*Security note*: Exporting keys as environment variables directly in the shell is not recommended for production use as they can be surfaced from your shell history. Instead, it may be better to set this in your shell configuration file (`.bashrc`, `.zshrc`, etc)

