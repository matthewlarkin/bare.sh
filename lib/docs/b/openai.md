
# openai

OpenAI API client

## Options

`chat`   Send a message to an AI model
`assistants.create`   Create a new assistant
`threads.create`   Create a new thread
`thread.messages.append`   Append a message to a thread
`thread.messages.list`   List messages in a thread
`thread.run`   Run an assistant on a thread
`thread.run.poll`   Poll the status of a thread run
`files.upload`   Upload a file to the OpenAI API
`files.list`   List files uploaded to the OpenAI API
`file.delete`   Delete a file from the OpenAI API
`images.create`   Generate images from a prompt
`audio.create`   Generate audio from a text prompt
`audio.transcribe`   Transcribe an audio file

## Examples

# Send a message to an AI model
> openai chat "What is the capital of France?"

# Create a new assistant
> openai assistants.create -n "My Assistant" -i "This is a helpful
assistant"

# Create a new thread
> openai threads.create -m "Hello, world!"

# Append a message to a thread
> openai thread.messages.append -t "thread_id" -m "Hello, world!"

# List messages in a thread
> openai thread.messages.list -t "thread_id"

