#!/bin/bash

[ ! -x "$(command -v curl)" ] && echo "🚨 curl is not installed" && exit 1
[ ! -x "$(command -v jq)" ] && echo "🚨 jq is not installed" && exit 1
[ -z "$OPENAI_API_KEY" ] && echo "🚨 OPENAI_API_KEY environment variable is not set" && exit 1

default_model="gpt-3.5-turbo-0125"

function curlRequest() {
    url="$1"
    payload="$2"

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
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "🌿 Usage: ./openai.sh assistants.create [name] [instructions] [model] 'tool_definition'"
            exit 1
        else
            assistant_name="$2" # Use a different variable name for the assistant's name
            instructions="$3"
        fi

        if [ -z "$4" ]; then
            model=$default_model
        else
            model="$4"
        fi

        if [ "$5" != "[]" ]; then
            tool_definition="$5"
            # Assume $5 is the input for the tools, which should be correctly split here
            IFS='|' read -r function_name description parameters_str <<< "$tool_definition"
        
            # Start constructing the JSON for the tool
            json=$(jq -n --arg fn "$function_name" --arg desc "$description" \
                '{
                    type: "function",
                    function: {
                        name: $fn,
                        description: $desc,
                        parameters: {
                            type: "object",
                            properties: {},
                            required: []
                        }
                    }
                }')
        
            # Split the parameters string into an array
            IFS=';' read -r -a parameters <<< "$parameters_str"
        
            # Process each parameter
            for param in "${parameters[@]}"; do
                IFS=':' read -r param_name param_type param_desc constraints <<< "$param" # Use different variable names for parameter attributes

                # Check if parameter is required
                if [[ $param_name == \** ]]; then
                    param_name="${param_name:1}"  # Remove asterisk from the name to mark it as required
                    json=$(echo $json | jq --arg n "$param_name" '.function.parameters.required += [$n]')
                fi
        
                # Handle enum constraint
                if [[ $constraints == [* ]]; then
                    enum_values=$(echo "$constraints" | tr -d '[]' | jq -R 'split(",")')
                    json=$(echo $json | jq --arg n "$param_name" --arg t "$param_type" --arg d "$param_desc" --argjson e "$enum_values" \
                        '.function.parameters.properties += {($n): {type: $t, description: $d, enum: $e}}')
                else
                    json=$(echo $json | jq --arg n "$param_name" --arg t "$param_type" --arg d "$param_desc" \
                        '.function.parameters.properties += {($n): {type: $t, description: $d}}')
                fi
            done
        
            tools=$(echo $json | jq -s '.')
        else
            tools="[]"
        fi

        payload=$(jq -n --arg name "$assistant_name" --arg instructions "$instructions" --arg model "$model" --argjson tools "$tools" '{
            instructions: $instructions,
            name: $name,
            model: $model,
            tools: $tools
        }')

        curlRequest "https://api.openai.com/v1/assistants" "$payload" | jq -r '{assistant_id: .id}'
        ;;


    "threads.create")
        [ -z "$2" ] && echo "🌿 ./openai.sh threads.create [initial_message]" && exit 0 || initial_message="$2"

        payload=$(jq -n --arg initial_message "$initial_message" '{
            messages: [ { role: "user", content: $initial_message } ]
        }')

        curlRequest "https://api.openai.com/v1/threads" "$payload" | jq -r '{thread_id: .id}'
        ;;

    "thread.messages.append")
        [ -z "$2" ] && echo "🌿 ./openai.sh thread.messages.append [thread_id] [message]" && exit 0 || thread_id="$2" && message="$3"

        payload=$(jq -n --arg role "user" --arg content "$message" '{
            role: $role,
            content: $content
        }')

        curlRequest "https://api.openai.com/v1/threads/$thread_id/messages" "$payload" | jq -r '{thread_id: .thread_id}'
        ;;

    "thread.messages.list")
        [ -z "$2" ] && echo "🌿 ./openai.sh thread.messages.list [thread_id] (limit)" && exit 0 || thread_id="$2" && limit="$3"
        [[ ! $limit =~ ^[0-9]+$ ]] && echo "🚨 2:limit must be an integer" && exit 1

        curlRequest "https://api.openai.com/v1/threads/$thread_id/messages?limit=$limit" "" | jq  '{thread_id: .data[0].thread_id, messages: [.data[] | {role: .role, value: .content[0].text.value, created_at: .created_at}]}'
        ;;

    "thread.run")
        [ -z "$2" ] && echo "🌿 ./openai.sh thread.run [thread_id] [assistant_id]" && exit 0 || thread_id="$2" && assistant_id="$3"

        payload=$(jq -n --arg assistant_id "$assistant_id" '{
            assistant_id: $assistant_id
        }')

        curlRequest "https://api.openai.com/v1/threads/$thread_id/runs" "$payload" | jq -r '{thread_id: .thread_id, run_id: .id, status: .status}'
        ;;

    "thread.run.poll")
        [ -z "$2" ] && echo "🌿 ./openai.sh thread.run.poll [thread_id] [run_id]" && exit 0 || thread_id="$2" && run_id="$3"

        curlRequest "https://api.openai.com/v1/threads/$thread_id/runs/$run_id" | jq -r '{thread_id: .thread_id, run_id: .id, status: .status}'
        ;;

    *)
        echo "🚨 Invalid command"
        exit 1
        ;;
esac
