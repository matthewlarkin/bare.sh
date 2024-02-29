#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/init"

create_run_and_poll() {

    echo -e "${muted}\n   Polling for AI response...${reset}"

    local thread_id="$1"
    local assistant_id="$2"
    local message="$3"

    b/openai thread.messages.append -t "$thread_id" -m "$message"

    local run_id=$(b/openai thread.run -t "$thread_id" -a "$assistant_id")

    while true; do
        local status=$(b/openai thread.run.poll -t "$thread_id" -r "$run_id")
        [[ "$status" != "in_progress" && "$status" != "queued" ]] && break
        sleep 1
    done

    echo -e "\n🤖 ${green}ASSISTANT${reset}: $(b/openai thread.messages.list -t "$thread_id" -J | jq -r '.messages[0].value')"
}

while true; do
    printf "\n✨ Do you want to create a NEW assistant or use an EXISTING one? (n/e): " && read assistant_choice

    if [[ "$assistant_choice" == "new" || "$assistant_choice" == "n" ]]; then
        printf "\n✨ Enter assistant name (for internal use): " && read -r assistant_name
        printf "\n✨ Enter system prompt (tell the assistant who they are and what to do): " && read -r system_prompt
        echo -e "${muted}\nAssistant created with id: $(b/openai assistants.create -n "$assistant_name" -i "$system_prompt" -t "code_interpreter|retrieval")${reset}"
        break
    elif [[ "$assistant_choice" == "existing" || "$assistant_choice" == "e" ]]; then
        printf "\n✨ Enter existing assistant id: " && read assistant_id
        break
    else
        b/error -w 4 "Invalid choice" "Please enter 'n' or 'e'"
    fi
done

printf "\n🧑 ${yellow}USER${reset}: " && read -r initial_message
thread_id=$(b/openai threads.create -m "$initial_message")
echo -e "${muted}\nThread created with id: $thread_id${reset}"
create_run_and_poll "$thread_id" "$assistant_id" "$initial_message"

trap "echo -e '\n\n👋 Goodbye!\n\n'; exit 0" SIGINT SIGTERM

while true; do
    printf "\n🧑 ${yellow}USER${reset}: " && read question
    create_run_and_poll "$thread_id" "$assistant_id" "$(printf '%s' "$question")"
done
