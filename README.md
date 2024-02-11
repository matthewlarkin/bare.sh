
# openai.sh
A dead simple bash script for basic OpenAI API calls, without bells and whistles, that helps you steamline your interactions with chat, threads, and assistants.

This tool is designed to be straightforward, enabling quick and effective communication with OpenAI's powerful models without getting bogged down in complexity. Embrace the simplicity 🏖️.

## ⭐️ Features
- Create one-off chat requests
- Setup assistants
- Setup threads
- Run threads by assistants

> Future updates may introduce additional functionalities like function calling, file uploads, embeddings, etc. For now, this script only covers the essential chat functionality -- **which you can do a lot with**! 🚀

## ⭐️ Prerequisites
Ensure you have set the `OPENAI_API_KEY` in your environment. This key is necessary for authenticating your requests to OpenAI. You can add it to your `.bashrc`, `.zshrc`, or equivalent:

```bash
export OPENAI_API_KEY='sk-xxxxxxxxxxxxxxxxxxxxxxxx'
```

> *Be cautious about exposing your API key in shell history.*

## ⭐️ Installation
Clone the repo or download the script directly. Put it in your path or call it directly from the directory.

```bash
# clone it
git clone https://github.com/matthewlarkin/openai
cd openai
chmod 700 openai.sh
```
```bash
# download the file directly
curl -O https://raw.githubusercontent.com/matthewlarkin/openai/main/openai.sh
chmod 700 openai.sh
```

## ⭐️ Getting Started

### Quick examples
**Simple chat, returning full JSON response**
```bash
./openai.sh chat "What's the weather like in Tokyo?"
```
```json
{
    "response" : "As an AI language model, I don't have up-to-date weather info, but I can point you to a function of yours that does!"
}
```
-------
**Create an assistant, returning the assistant ID JSON formatted string**
```bash
./openai.sh assistants.create "Travel Buddy" "Provide travel advice and information." | jq '.assistand_id'
```
```json
"asst_xxxxxxxxxxxxx"
```
-------
**Create a thread, returning plaintext string**
```bash
./openai.sh threads.create "I'm planning a trip to Japan." | jq -r '.thread_id'
```
```plaintext
thrd_xxxxxxxxxxxxx
```

Invoke the script with an available command, followed by its arguments. `[]` = required; `()` = optional. Responses are in JSON format, which is easily parsed with `jq` or similar tools.

**Available commands**
- `chat` [message] (model)
- `assistants.create` [name] [description]
- `threads.create` [initial_message]
- `thread.messages.append` [thread_id] [message]
- `thread.messages.list` [thread_id] (limit)
- `thread.run` [thread_id] [assistant_id]
- `thread.run.poll` [thread_id] [run_id]

> If you forget the syntax, simply call the command with no arguments, and we'll extend an olive branch to guide you 👌

```bash
./openai.sh chat
```

```bash
# output
🌿 ./openai.sh chat [message] (model) 👉 Returns {response}
```

### Command Examples

#### `chat`

Get a one-off response from an OpenAI model:

```bash
./openai.sh chat "What's the weather like in Tokyo?"
```
```json
{
    "response" : "As an AI language model, I don't have up-to-date weather info, but I can point you to a function of yours that does!"
}
```

#### `assistants.create`
We can create an assistant to handle more complex interactions. Give it a `name` and a `description`.

```bash
./openai.sh assistants.create "Travel Buddy" "Provide travel advice and information."
```
```json
{
    "assistant_id" : "asst_xxxxxxxxxxxxx"
}
```

#### `threads.create`
Create a thread to manage a conversation. Pass an `initial_message` to start the thread. Threads don't need a model or an assistant to start. We assign those later.

```bash
./openai.sh threads.create "I'm planning a trip to Japan."
```
```json
{
    "thread_id" : "thrd_xxxxxxxxxxxxx"
}
```

#### `thread.messages.append`
Add a message to an existing thread. Pass the `thread_id` and the new `message`.

```bash
./openai.sh thread.messages.append [thread_id] "Should I visit Kyoto or Osaka?"
```
```json
{
    "message_id" : "msg_xxxxxxxxxxxxx"
}
```

#### `thread.messages.list`
Display all messages within a thread. Defaults to 20 messages, but you can specify a limit (up to 100).

```bash
./openai.sh thread.messages.list thrd_xxxxxxxxxxxxx 40
```
```json
{
    "thread_id" : "thrd_xxxxxxxxxxxxx",
    "messages" : [
        {
            "role" : "assistant",
            "value" : "You should definitely visit Banff National Park!",
            "created_at" : "1707565321"
        },
        {
            "role" : "user",
            "value" : "Not yet. I'm open to Canada.",
            "created_at" : "1707565320"
        },
        {
            "role" : "assistant",
            "value" : "Do you have a country in mind? Canada has some great spots!",
            "created_at" : "1707565311"
        },
        {
            "role" : "user",
            "value" : "I'm planning a trip to the Rockies.",
            "created_at" : "1707565310"
        }
    ]
}
```

#### `thread.run`
Run a thread by an assistant for their input. Pass in the `thread_id` and the `assistant_id`.

```bash
./openai.sh thread.run [thread_id] [assistant_id]
```
```json
{
    "run_id" : "run_xxxxxxxxxxxxx"
}
```

#### `thread.run.poll`

Check the completion status of a run:

```bash
./openai.sh thread.run.poll [thread_id] [run_id]
```
```json
{
    "thread_id" : "thrd_xxxxxxxxxxxxx",
    "run_id" : "run_xxxxxxxxxxxxx",
    "status" : "queued"
}
```
```json
{
    "thread_id" : "thrd_xxxxxxxxxxxxx",
    "run_id" : "run_xxxxxxxxxxxxx",
    "status" : "in_progress"
}
```
```json
{
    "thread_id" : "thrd_xxxxxxxxxxxxx",
    "run_id" : "run_xxxxxxxxxxxxx",
    "status" : "completed"
}
```

### Example Workflow
Automate polling for a run's completion and retrieve the latest message. In this example, we create an assistant and a thread, then start a run and poll for completion. Once the run is completed, we retrieve the final message.

```bash
#!/bin/bash

# Creating an assistant and a thread. Normally, we'd pull
# this from a datastore, but for the sake of this
# example, we'll create them on the fly.
assistant_id=$(./openai.sh assistants.create "Adventure Guide" "Helps plan adventure trips." | jq -r '.assistant_id')
echo "✅ Assistant created: $assistant_id"
thread_id=$(./openai.sh threads.create "Planning an adventure in the Rockies." | jq -r '.thread_id')
echo "✅ Thread created: $thread_id"

# Now that we have an assistant and a thread, we can run
# the thread by the assistant and poll for completion.
run_id=$(./openai.sh thread.run $thread_id $assistant_id | jq -r '.run_id')
echo "✅ Run created: $run_id"
status=$(./openai.sh thread.run.poll $thread_id $run_id | jq -r '.status')
echo "🔄 Polling for completion..."

# Polling...
while [[ "$status" == "in_progress" || "$status" == "queued" ]]; do
    sleep 2 # Adjust polling interval as needed
    status=$(./openai.sh thread.run.poll $thread_id $run_id | jq -r '.status')
    [ "$status" == "in_progress" ] && echo "🔄 🙄..."
    [ "$status" == "completed" ] && echo "🔄 👀"
done

# If we've reached this point, the run is completed.
# Let's retrieve the latest message (passing the
# thread_id and a limit of 1).
if [[ "$status" == "completed" ]]; then
    echo "🎉 Run completed!"
    echo "🤖 ASSISTANT: $(./openai.sh thread.messages.list $thread_id 1 | jq -r '.messages[0].value')"
fi
```
Run the script and observe the output:

```bash
bash ./example.sh
```
Output:
```plaintext
✅ Assistant created: asst_mPzxldkzQKf9Cuj1ROySai94
✅ Thread created: thread_xkKBONqV2gHlxe9Ne0G4X1df
✅ Run created: run_S4QZtQ58qTIQC5HS9r4pUsVr
🔄 Polling for completion...
🔄 🙄...
🔄 👀
🎉 Run completed!
🤖 ASSISTANT: "You should definitely visit Banff National Park!"
```
