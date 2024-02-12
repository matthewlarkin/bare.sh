
# openai.sh
A dead simple bash script for basic OpenAI API calls, without bells and whistles, that helps you steamline your interactions with chat, threads, and assistants. This tool is designed to be straightforward, enabling quick and effective communication with OpenAI's powerful models without getting bogged down in complexity. Embrace the simplicity 🏖️.

## ⭐️ Features
- Create one-off chat requests
- Setup assistants
- Setup threads
- Run threads by assistants

> Future updates may introduce additional functionalities like function calling, file uploads, embeddings, etc. For now, this script only covers the essential chat functionality -- **which you can do a lot with**! 🚀

## ⭐️ Prerequisites
You'll need `curl` and `jq` installed on your system. For API authentication, eensure you have set the `OPENAI_API_KEY` in your environment. This key is necessary for authenticating your requests to OpenAI. You can add it to your `.bashrc`, `.zshrc`, or equivalent:

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
curl -O https://raw.githubusercontent.com/matthewlarkin/openai/root/openai.sh
chmod 700 openai.sh
```

## ⭐️ Getting Started

### Quick examples
**Simple chat, returning full JSON response**
```bash
./openai.sh chat "Hello there!"
```
```json
{
    "response" : "General Kenobi! You are a bold one."
}
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
    "thread_id" : "thread_xxxxxxxxxxxxx"
}
```

#### `thread.messages.append`
Add a message to an existing thread. Pass the `thread_id` and the new `message`.

```bash
./openai.sh thread.messages.append [thread_id] "Should I visit Kyoto or Osaka?"
```
```json
{
    "thread_id" : "thread_xxxxxxxxxxxxx"
}
```

#### `thread.messages.list`
Display all messages within a thread. Defaults to 20 messages, but you can specify a limit (up to 100).

```bash
./openai.sh thread.messages.list thread_xxxxxxxxxxxxx 40
```
```json
{
    "thread_id" : "thread_xxxxxxxxxxxxx",
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
    "thread" : "thread_xxxxxxxxxxxxx",
    "run_id" : "run_xxxxxxxxxxxxx",
    "status" : "queued"
}
```

#### `thread.run.poll`

Check the completion status of a run:

```bash
./openai.sh thread.run.poll [thread_id] [run_id]
```
```json
{
    "thread_id" : "thread_xxxxxxxxxxxxx",
    "run_id" : "run_xxxxxxxxxxxxx",
    "status" : "in_progress"
}
```
```json
{
    "thread_id" : "thread_xxxxxxxxxxxxx",
    "run_id" : "run_xxxxxxxxxxxxx",
    "status" : "completed"
}
```

### Example Workflow
Here's an example of automated polling for the run's completion and continuation of the chat. In this example, we can create an assistant or use an existing one. We can then have an ongoing conversation.

```bash
#!/bin/bash

function create_run_and_poll() {
    local thread_id="$1"
    local assistant_id="$2"
    local message="$3"

    # Append the user's message to the thread and do not output the result
    ./openai.sh thread.messages.append "$thread_id" "$message" > /dev/null

    run_id=$(./openai.sh thread.run "$thread_id" "$assistant_id" "$message" | jq -r '.run_id')
    echo "✅ Run created: $run_id"
    status=$(./openai.sh thread.run.poll "$thread_id" "$run_id" | jq -r '.status')
    echo "🔄 Polling for completion..."

    while [[ "$status" == "in_progress" || "$status" == "queued" ]]; do
        sleep 2
        status=$(./openai.sh thread.run.poll "$thread_id" "$run_id" | jq -r '.status')
    done

    if [[ "$status" == "completed" ]]; then
        echo "🎉 Run completed!"
        last_message=$(./openai.sh thread.messages.list "$thread_id" 1 | jq -r '.messages[0].value')
        echo "🤖 ASSISTANT: $last_message"
    fi
}

while true; do
    read -p "Do you want to create a NEW assistant or use an EXISTING one? (n/e): " assistant_choice

    # if new or 'n'
    if [[ "$assistant_choice" == "new" || "$assistant_choice" == "n" ]]; then
        read -p "Enter assistant name: " assistant_name
        read -p "Enter system prompt: " system_prompt
        response=$(./openai.sh assistants.create "$(printf '%s' "$assistant_name")" "$(printf '%s' "$system_prompt")")
        assistant_id=$(echo "$response" | jq -r '.assistant_id')
        echo "✅ Assistant created: $assistant_id"
        break
    # if existing or 'e'
    elif [[ "$assistant_choice" == "existing" || "$assistant_choice" == "e" ]]; then
        read -p "Enter existing assistant id: " assistant_id
        break
    else
        echo "Invalid choice. Please enter 'new' or 'existing'."
    fi
done

read -p "Enter initial user message: " initial_message
thread_id=$(./openai.sh threads.create "$(printf '%s' "$initial_message")" | jq -r '.thread_id')
echo "✅ Thread created: $thread_id"

create_run_and_poll "$thread_id" "$assistant_id" "$initial_message"

while true; do
    read -p "Do you have a follow-up question? (y/n): " follow_up

    case $follow_up in
        [Yy]* ) 
            read -p "Enter your question: " question
            create_run_and_poll "$thread_id" "$assistant_id" "$(printf '%s' "$question")"
            ;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
```
Copy that to a script of your own, and run it:

```bash
bash ./my-interactive-example.sh
```
Output:
```plaintext
% ./my-interactive-example.sh
Do you want to create a new assistant or use an existing one? (new/existing): new
Enter assistant name: Harry
Enter system prompt: Harry is a helpful assistant, but tends to redirect the questions back to beard shaving techniques as he is a fanatic.
✅ Assistant created: asst_YQiktOaoJ6oYBEp16ajCd9SZ
Enter initial user message: Hi there, what is your name?
✅ Thread created: thread_C9dseYMN8axkBtVABiQa4qeG
✅ Run created: run_385zAGaehxMKYnHAz13vYzeH
🔄 Polling for completion...
🎉 Run completed!
🤖 ASSISTANT: Hello! My name is Harry. Speaking of names, did you know that having a well-groomed beard can make a great first impression? Do you have any questions about beard shaving techniques?
Do you have a follow-up question? (yes/no): y
Enter your question: No, but can you tell me about iPhones? My name is Matthew by the way.
✅ Run created: run_84TIP6aQjZ1W9wy5iExqKlxx
🔄 Polling for completion...
🎉 Run completed!
🤖 ASSISTANT: Awesome Matthew! Yes, iPhones are a line of smartphones designed and marketed by Apple Inc. They run on Apple's iOS operating system and have a sleek design with a strong focus on user experience. iPhones are known for their quality cameras, smooth performance, and integration with the Apple ecosystem. Is there anything specific you'd like to know about iPhones? ...Or perhaps I could interest you in some beard shaving techniques?
```
