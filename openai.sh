#!/bin/bash

# Expects an OPENAI_API_KEY environment variable to be set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "OPENAI_API_KEY environment variable is not set"
    exit 1
fi

OPENAI_API_KEY=$(printf '%q' "$OPENAI_API_KEY")


# Simple Chat Response
# Returns the response
if [ "$1" == "chat" ]; then
    # if $2 is 'help' then print help
    if [ "$2" == "help" ]; then
        echo "🌿 chat <message> [model] 👉 Returns the response as a string"
        exit 0
    fi
    if [ -z "$2" ]; then
        echo "🚨 chat requires a message"
        exit 1
    fi
    # check for given model
    if [ -z "$3" ]; then
        model="gpt-3.5-turbo-0125"
    else
        model="$3"
    fi
    message="$2"
    message_payload=$(jq -n --arg model "$model" --arg content "$message" '{
        model: $model,
        messages: [
            {
                role: "user",
                content: $content
            }
        ]
    }')
    curl "https://api.openai.com/v1/chat/completions" \
        --silent \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$message_payload" | jq -r '.choices[0].message.content'
fi


# Create an assistant
# Returns the assistant_id
if [ "$1" == "assistants.create" ]; then
    if [ "$2" == "help" ]; then
        echo "🌿 assistants.create <name> <instructions> [model] 👉 Returns the assistant_id as a string"
        exit 0
    fi
    if [ -z "$2" ]; then
        echo "🚨 assistants.create requires a name"
        exit 1
    fi
    if [ -z "$3" ]; then
        echo "🚨 assistants.create requires instructions"
        exit 1
    fi
    name="$2"
    instructions="$3"
    model="$4"
    if [ -z "$model" ]; then
        model="gpt-3.5-turbo-0125"
    fi
    payload=$(jq -n --arg instructions "$instructions" --arg name "$name" --arg model "$model" '{
        instructions: $instructions,
        name: $name,
        model: $model
    }')
    curl "https://api.openai.com/v1/assistants" \
        --silent \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "OpenAI-Beta: assistants=v1" \
        -d "$payload" | jq -r '.id'
fi
        


# Create a new thread
# Returns the thread_id
if [ "$1" == "threads.create" ]; then
    if [ "$2" == "help" ]; then
        echo "🌿 threads.create <initial_message> 👉 Returns the thread_id as a string"
        exit 0
    fi
    if [ -z "$2" ]; then
        echo "🚨 threads.create requires an initial message"
        exit 1
    fi
    initial_message="$2"
    payload=$(jq -n --arg initial_message "$initial_message" '{
        messages: [
            {
                role: "user",
                content: $initial_message
            }
        ]
    }')
    curl https://api.openai.com/v1/threads \
        --silent \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H 'Content-Type: application/json' \
        -H 'OpenAI-Beta: assistants=v1' \
        -d "$payload" | jq -r '.id'
fi


# Append a message to a thread
# Returns the message_id
if [ "$1" == "thread.messages.append" ]; then
    if [ "$2" == "help" ]; then
        echo "🌿 thread.messages.append <thread_id> <message> 👉 Returns the message_id as a string"
        exit 0
    fi
    if [ -z "$2" ]; then
        echo "🚨 thread.messages.append requires a thread_id"
        exit 1
    fi
    if [[ $2 == *" "* ]]; then
        echo "🚨 thread_id cannot contain spaces"
        exit 1
    fi
    if [ -z "$3" ]; then
        echo "🚨 thread.messages.append requires a message"
        exit 1
    fi
    thread_id=$(printf '%q' "$2")
    message="$3"
    payload=$(jq -n --arg role "user" --arg content "$message" '{
        role: $role,
        content: $content
    }')
    curl https://api.openai.com/v1/threads/$thread_id/messages \
        --silent \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "OpenAI-Beta: assistants=v1" \
        -d "$payload" | jq -r '.thread_id'
fi


# List all messages in a thread
# Returns an array of messages
if [ "$1" == "thread.messages.list" ]; then
    if [ "$2" == "help" ]; then
        echo "🌿 thread.messages.list <thread_id> [limit '20'] 👉 Returns an array of messages"
        exit 0
    fi
    if [ -z "$2" ]; then
        echo "🚨 thread.messages.list requires a thread_id"
        exit 1
    fi
    if [[ $2 == *" "* ]]; then
        echo "🚨 thread_id cannot contain spaces"
        exit 1
    fi
    thread_id=$(printf '%q' "$2")
    if [ -z "$3" ]; then
        limit=20
    else
        limit="$3"
        if ! [[ $limit =~ ^[0-9]+$ ]]; then
            echo "🚨 limit must be an integer"
            exit 1
        fi
    fi
    curl https://api.openai.com/v1/threads/$thread_id/messages?limit=$limit \
        --silent \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H 'Content-Type: application/json' \
        -H 'OpenAI-Beta: assistants=v1' | jq  '{thread_id: .data[0].thread_id, messages: [.data[] | {role: .role, value: .content[0].text.value, created_at: .created_at}]}'
fi


# Create run with an assistant and thread
# Returns the run_id
if [ "$1" == "thread.runs.create" ]; then
    if [ "$2" == "help" ]; then
        echo "🌿 thread.runs.create <assistant_id> <thread_id> 👉 Returns the run_id as a string"
        exit 0
    fi
    if [ -z "$2" ]; then
        echo "🚨 requires an assistant_id"
        exit 1
    fi
    if [ -z "$3" ]; then
        echo "🚨 requires a thread_id"
        exit 1
    fi
    if [[ $2 == *" "* ]]; then
        echo "🚨 assistant_id cannot contain spaces"
        exit 1
    fi
    if [[ $3 == *" "* ]]; then
        echo "🚨 thread_id cannot contain spaces"
        exit 1
    fi
    assistant_id="$2"
    thread_id=$(printf '%q' "$3")
    payload=$(jq -n --arg assistant_id "$assistant_id" '{
        assistant_id: $assistant_id
    }')
    curl "https://api.openai.com/v1/threads/$thread_id/runs" \
        --silent \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H 'Content-Type: application/json' \
        -H 'OpenAI-Beta: assistants=v1' \
        -d "$payload" | jq -r '.id'
fi


# Poll for completion of a run
# Returns an object { "thread_id": <string>, "run_id", <string>, "status": <string> [queued | completed] }
if [ "$1" == "thread.run.poll" ]; then
    if [ "$2" == "help" ]; then
        echo "🌿 thread.run.poll <thread_id> <run_id> 👉 Returns an object with thread_id and status"
        exit 0
    fi
    if [ -z "$2" ]; then
        echo "🚨 requires a thread_id"
        exit 1
    fi
    if [ -z "$3" ]; then
        echo "🚨 requires a run_id"
        exit 1
    fi
    if [[ $2 == *" "* ]]; then
        echo "🚨 thread_id cannot contain spaces"
        exit 1
    fi
    if [[ $3 == *" "* ]]; then
        echo "🚨 run_id cannot contain spaces"
        exit 1
    fi
    thread_id=$(printf '%q' "$2")
    run_id=$(printf '%q' "$3")
    curl https://api.openai.com/v1/threads/$thread_id/runs/$run_id \
        --silent \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "OpenAI-Beta: assistants=v1" | jq
fi
