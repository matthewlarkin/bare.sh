#!/bin/bash

[ -z "$OPENAI_API_KEY" ] && echo "🚨 OPENAI_API_KEY environment variable is not set" && exit 1

default_model="gpt-3.5-turbo-0125"

function curlRequest() {
    url=$1
    payload=$2

    if [[ -z "$payload" ]]; then
        response=$(curl -G "$url" --silent -H "Content-Type: application/json" -H "Authorization: Bearer $OPENAI_API_KEY" -H "OpenAI-Beta: assistants=v1" | jq -r)
    else
        response=$(curl "$url" --silent -H "Content-Type: application/json" -H "Authorization: Bearer $OPENAI_API_KEY" -d "$payload" -H "OpenAI-Beta: assistants=v1" | jq -r)
    fi

    echo "$response"
}

# Simple one-off chat
case $1 in

    "chat")
        [ -z "$2" ] && echo "🌿 ./openai.sh chat [my-message]" && exit 0 || message="$2"
        [ -z "$3" ] && model=$default_model || model="$3"

        message_payload=$(jq -n --arg model "$model" --arg content "$message" '{
            model: $model,
            messages: [ { role: "user", content: $content } ]
        }')

        curlRequest "https://api.openai.com/v1/chat/completions" "$message_payload" | jq -r '{response: .choices[0].message.content}'
        ;;

    "assistants.create")
        [ -z "$2" ] || [ -z "$3" ] && { echo "🌿 ./openai.sh assistants.create [name] [instructions]" && exit 0; } || { name="$2"; instructions="$3"; }

        [ -z "$4" ] && model=$default_model || model="$4"

        payload=$(jq -n --arg instructions "$instructions" --arg name "$name" --arg model "$model" '{
            instructions: $instructions,
            name: $name,
            model: $model
        }')

        curlRequest "https://api.openai.com/v1/assistants" "$payload" | jq -r '{assistant_id: .id}'
        ;;

    "threads.create")
        [ -z "$2" ] && { echo "🌿 ./openai.sh threads.create [initial_message]" && exit 0; } || initial_message="$2"

        payload=$(jq -n --arg initial_message "$initial_message" '{
            messages: [ { role: "user", content: $initial_message } ]
        }')

        curlRequest "https://api.openai.com/v1/threads" "$payload" | jq -r '{thread_id: .id}'
        ;;

    "thread.messages.append")
        [ -z "$2" ] || [ -z "$3" ] && echo "🌿 ./openai.sh thread.messages.append [thread_id] [message]" && exit 0 || thread_id="$2" && message="$3"

        payload=$(jq -n --arg role "user" --arg content "$message" '{
            role: $role,
            content: $content
        }')

        curlRequest "https://api.openai.com/v1/threads/$thread_id/messages" "$payload" | jq -r '{thread_id: .thread_id}'
        ;;

    "thread.messages.list")
        [ -z "$2" ] || [ -z "$3" ] && echo "🌿 ./openai.sh thread.messages.list [thread_id] (limit)" && exit 0 || thread_id="$2" && limit="$3"
        [[ ! $limit =~ ^[0-9]+$ ]] && echo "🚨 2:limit must be an integer" && exit 1

        curlRequest "https://api.openai.com/v1/threads/$thread_id/messages?limit=$limit" "" | jq  '{thread_id: .data[0].thread_id, messages: [.data[] | {role: .role, value: .content[0].text.value, created_at: .created_at}]}'
        ;;

    "thread.run")
        [ -z "$2" ] || [ -z "$3" ] && echo "🌿 ./openai.sh thread.run [thread_id] [assistant_id]" && exit 0 || thread_id="$2" && assistant_id="$3"

        payload=$(jq -n --arg assistant_id "$assistant_id" '{
            assistant_id: $assistant_id
        }')

        curlRequest "https://api.openai.com/v1/threads/$thread_id/runs" "$payload" | jq -r '{thread_id: .thread_id, run_id: .id, status: .status}'
        ;;

    "thread.run.poll")
        [ -z "$2" ] || [ -z "$3" ] && { echo "🌿 ./openai.sh thread.run.poll [thread_id] [run_id]" && exit 0; } || thread_id="$2" && run_id="$3"

        curlRequest "https://api.openai.com/v1/threads/$thread_id/runs/$run_id" | jq -r '{thread_id: .thread_id, run_id: .id, status: .status}'
        ;;

    *)
        echo "🚨 Invalid command"
        exit 1
        ;;
esac
