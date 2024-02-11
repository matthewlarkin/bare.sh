
# openai.sh
A bash script to simplify OpenAI API calls, streamlining interactions with chat, threads, and assistants.

This tool is designed to be straightforward, enabling quick and effective communication with OpenAI's powerful models without getting bogged down in complexity. Embrace the simplicity 🏖️.

## Features
- Create one-off chat requests
- Setup assistants
- Setup threads
- Run threads by assistants

⏳ Future updates may introduce additional functionalities like file uploads, endpoint customization, embeddings, etc. For now, this script only covers the essential chat functionality -- which you can do a lot with! 🚀

## Prerequisites
Ensure you have set the `OPENAI_API_KEY` in your environment. This key is necessary for authenticating your requests to OpenAI. You can add it to your `.bashrc`, `.zshrc`, or equivalent:

```bash
export OPENAI_API_KEY='sk-xxxxxxxxxxxxxxxxxxxxxxxx'
```

> *Be cautious about exposing your API key in shell history.*

## Getting Started
Invoke the script with any command, followed by arguments. Pass `help` as the sole argument to any command to receive guidance on that command's usage:

```bash
# Need a refresher on the chat command?
./openai.sh chat help
```

```bash
# output
🌿 ./openai.sh chat <message> [model] 👉 Returns {response}
```

### Commands

#### `chat`

Get a one-off response from an OpenAI model:

```bash
./openai.sh chat "What's the weather like in Tokyo?"
```

#### `assistants.create`

Set up a new assistant:

```bash
./openai.sh assistants.create "Travel Buddy" "Provide travel advice and information."
```

#### `threads.create`

Start a new conversation thread:

```bash
./openai.sh threads.create "I'm planning a trip to Japan."
```

#### `thread.messages.append`

Add a follow-up message to an existing thread:

```bash
./openai.sh thread.messages.append <thread_id> "Should I visit Kyoto or Osaka?"
```

#### `thread.messages.list`

Display all messages within a thread:

```bash
./openai.sh thread.messages.list <thread_id> 20
```

#### `thread.run`

Execute a thread through an assistant:

```bash
./openai.sh thread.run <thread_id> <assistant_id>
```

#### `thread.run.poll`

Check the completion status of a run:

```bash
./openai.sh thread.run.poll <thread_id> <run_id>
```

### Example Workflow

Automate polling for a run's completion and retrieve the latest message. In this example, we create an assistant and a thread, then start a run and poll for completion. Once the run is completed, we retrieve the final message.

```bash
#!/bin/bash

# Creating an assistant and a thread. Normally, we'd pull
# this from a datastore, but for the sake of this
# example, we'll create them on the fly.
assistant_id=$(./openai.sh assistants.create "Adventure Guide" "Helps plan adventure trips." | jq -r '.assistant_id')
echo "✅ Assistant ID: $assistant_id"
thread_id=$(./openai.sh threads.create "Planning an adventure in the Rockies." | jq -r '.thread_id')
echo "✅ Thread ID: $thread_id"

# Now that we have an assistant and a thread, we can run
# the thread by the assistant and poll for completion.
run_id=$(./openai.sh thread.run $thread_id $assistant_id | jq -r '.run_id')
echo "✅ Run ID: $run_id"
status=$(./openai.sh thread.run.poll $thread_id $run_id | jq -r '.status')
echo "🔄 Polling for completion..."

# Polling...
while [[ "$status" == "in_progress" || "$status" == "queued" ]]; do
    sleep 2 # Adjust polling interval as needed
    echo "🔄 🙄..."
    status=$(./openai.sh thread.run.poll $thread_id $run_id | jq -r '.status')
done

# If we've reached this point, the run is completed.
# Let's retrieve the latest message (passing the
# thread_id and a limit of 1).
if [[ "$status" == "completed" ]]; then
    echo "🎉 Run completed!"
    echo("📜 Latest message: $(./openai.sh thread.messages.list $thread_id 1 | jq -r '.data[0].value')")
fi
```
```bash
# output from above script
☑️ Assistant ID: asst_xxxxxxxxxxxxx
☑️ Thread ID: thrd_xxxxxxxxxxxxx
☑️ Run ID: run_xxxxxxxxxxxxx
🔄 Polling for completion...
🔄 🙄...
✅ Run completed!
🤖 ASSISTANT: "You should definitely visit Banff National Park!"
```
