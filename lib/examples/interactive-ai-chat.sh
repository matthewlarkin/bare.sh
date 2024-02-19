source lib/colors

[ -f ./b/openai ] || {
    echo "🚨 Could not find openai"
    exit 1
}

function create_run_and_poll() {

    local thread_id="$1"
    local assistant_id="$2"
    local message="$3"

    bin/openai thread.messages.append -t "$thread_id" -m "$message" > /dev/null

    run_id=$(bin/openai thread.run -t "$thread_id" -a "$assistant_id")
    run_id=$(echo "$run_id" | jq -r '.run_id')

    status=$(bin/openai thread.run.poll -t "$thread_id" -r "$run_id")
    status=$(echo "$status" | jq -r '.status')
    echo -e "${muted}\n   Polling for AI response...${reset}"

    while [[ "$status" == "in_progress" || "$status" == "queued" ]]; do
        sleep 2
        status=$(bin/openai thread.run.poll -t "$thread_id" -r "$run_id" | jq -r '.status')
    done

    if [[ "$status" == "completed" ]]; then
        last_message=$(bin/openai thread.messages.list -t "$thread_id" | jq -r '.messages[0].value')
        echo -e "\n🤖 ${green}ASSISTANT${reset}: $last_message"
    fi

}

while true; do
    printf "\n✨ Do you want to create a NEW assistant or use an EXISTING one? (n/e): " && read assistant_choice

    if [[ "$assistant_choice" == "new" || "$assistant_choice" == "n" ]]; then
        printf "\n✨ Enter assistant name: " && read -r assistant_name
        printf "\n✨ Enter system prompt: " && read -r system_prompt
        response=$(bin/openai assistants.create -n "$assistant_name" -i "$system_prompt" -t "code_interpreter|retrieval")
        assistant_id=$(echo "$response" | jq -r '.assistant_id')
        echo -e "${muted}\nAssistant created with id: $assistant_id${reset}"
        break
    elif [[ "$assistant_choice" == "existing" || "$assistant_choice" == "e" ]]; then
        printf "\n✨ Enter existing assistant id: " && read assistant_id
        break
    else
        bin/error -w 4 "Invalid choice" "Please enter 'n' or 'e'"
    fi
done

printf "\n🧑 ${yellow}USER${reset}: " && read -r initial_message
thread_id=$(bin/openai threads.create -m "$initial_message" | jq -r '.thread_id')

create_run_and_poll "$thread_id" "$assistant_id" "$initial_message"

trap "echo -e '\n\n👋 Goodbye!\n\n'; exit 0" SIGINT SIGTERM

while true; do
    printf "\n🧑 ${yellow}USER${reset}: " && read question
    create_run_and_poll "$thread_id" "$assistant_id" "$(printf '%s' "$question")"
done