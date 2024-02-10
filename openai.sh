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
        echo "🌿 chat <message> 👉 Returns the response as a string"
        exit 0
    fi
    if [ -z "$2" ]; then
        echo "🚨 chat requires a message"
        exit 1
    fi
    message=$(printf '%q' "$2")
    curl "https://api.openai.com/v1/chat/completions" \
        --silent \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d '{"model": "gpt-3.5-turbo","messages": [{"role": "user", "content": "'"$message"'"}]}' | jq -r '.choices[0].message.content'
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
    name=$(printf '%q' "$2")
    instructions=$(printf '%q' "$3")
    model=$(printf '%q' "$4")
    if [ -z "$model" ]; then
        model="gpt-3.5-turbo-0125"
    fi
    curl "https://api.openai.com/v1/assistants" \
        --silent \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "OpenAI-Beta: assistants=v1" \
        -d "{
            \"instructions\": \"$instructions\",
            \"name\": \"$name\",
            \"model\": \"$model\"
        }" | jq -r '.id'
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
    message=$(printf '%q' "$2")
    curl https://api.openai.com/v1/threads \
        --silent \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H 'Content-Type: application/json' \
        -H 'OpenAI-Beta: assistants=v1' \
        -d "{
            \"messages\": [
                {
                    \"role\": \"user\",
                    \"content\": \"$message\"
                }
            ]
        }" | jq -r '.id'
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
    message=$(printf '%q' "$3")
    curl https://api.openai.com/v1/threads/$thread_id/messages \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "OpenAI-Beta: assistants=v1" \
        -d "{
            \"role\": \"user\",
            \"content\": \"$message\"
        }" | jq -r '.id'
fi


# List all messages in a thread
# Returns an array of messages
if [ "$1" == "thread.messages.list" ]; then
    if [ "$2" == "help" ]; then
        echo "🌿 thread.messages.list <thread_id> 👉 Returns an array of messages"
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
    message=$(printf '%q' "$2")
    curl https://api.openai.com/v1/threads/$thread_id/messages \
        --silent \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H 'Content-Type: application/json' \
        -H 'OpenAI-Beta: assistants=v1' | jq -r '.data[] | {role: .role, message: .content[].text.value}'
fi


# Create run with an assistant and thread
# Returns the run_id
if [ "$1" == "runs.create" ]; then
    if [ "$2" == "help" ]; then
        echo "🌿 runs.create <assistant_id> <thread_id> 👉 Returns the run_id as a string"
        exit 0
    fi
    if [ -z "$2" ]; then
        echo "🚨 runs.create requires an assistant_id"
        exit 1
    fi
    if [ -z "$3" ]; then
        echo "🚨 runs.create requires a thread_id"
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
    assistant_id=$(printf '%q' "$2")
    thread_id=$(printf '%q' "$3")
    curl "https://api.openai.com/v1/threads/$thread_id/runs" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H 'Content-Type: application/json' \
        -H 'OpenAI-Beta: assistants=v1' \
        -d "{
            \"assistant_id\": \"$assistant_id\"
        }" | jq
fi


# Poll for completion of a run
# If not complete, returns null, otherwise returns the thread_id
if [ "$1" == "run.poll" ]; then
    if [ "$2" == "help" ]; then
        echo "🌿 run.poll <thread_id> <run_id> 👉 Returns the thread_id as a string"
        exit 0
    fi
    if [ -z "$2" ]; then
        echo "🚨 run.poll requires a thread_id"
        exit 1
    fi
    if [ -z "$3" ]; then
        echo "🚨 run.poll requires a run_id"
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
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "OpenAI-Beta: assistants=v1" | jq -r '.data | if .status == "completed" then .thread_id else null end'
fi
