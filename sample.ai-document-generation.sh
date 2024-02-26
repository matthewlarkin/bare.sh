#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/init"

cli_print() {
    local text=$1
    local line_break=60
    echo -e "$text" | fold -s -w "$line_break" | awk '1'
}

hr="\n| - - - 🌿 - - 🌿 - - 🌿 - - ⭐️ - - 🌿 - - 🌿 - - 🌿 - - - |\n"

cli_print "$hr"

cli_print "\nWelcome to the GroveOS! This script is a sample that demonstrates how to use the GroveOS CLI to call out to OpenAI API to generate a markdown note, save the note to your notes store, pass that note to an Assistant, and start asking interactive questions about the note."

cli_print "\nWe encourage you to study the source code of this bash script and use it as a starting point for your own GroveOS CLI scripting.\n\n - - - \n"

cli_print "First, let's generate a note about learning bash scripting. We'll include three markdown tasks related to the content."

read -rp $'\n ✨ What subject would you like to learn about? ' subject

echo -e "\nGenerating a note about learning $subject..."

# Create an ai-generated note
note=$(b/openai chat -m "Return a three paragraph markdown document about learning $subject. At the end, include three markdown task checklists related to the content to help me learn." | jq -r .response)

# Add the note to the 'home' notebook
b/notes add -N 'home' -T "Learn $subject" -C "$note" -f "learn-$subject.md" > /dev/null

cli_print "\n📝 ${green}Note created and saved to your notes store.${reset}\n"

# Create an assistant to help with the note
assistant=$(b/openai assistants.create -n "${subject} teacher" -i "You are a ${subject} teacher." -t "retrieval" | jq -r .assistant_id)

# Upload the note to OpenAI and prepare the comma-separated list
file_id=$(b/openai files.upload -f "$BARE_NOTES_DIR/home/learn-$subject.md" | jq -r '.file_id')

# Create a thread to interact with the assistant
thread_id=$(b/openai threads.create -m 'Hi there. Can you sum up the attached document in one sentence please?' -f "$file_id" | jq -r '.thread_id')

# make sure the file has been processed (should get status = processed)
while true; do
    file_status=$(b/openai file.show -f "$file_id" | jq -r '.status')
    [[ "$file_status" == "processed" ]] && break
    sleep 2
done

# Run the thread by the assistant
run_id=$(b/openai thread.run -t "$thread_id" -a "$assistant" | jq -r .run_id)

# Poll for the response
while true; do
    run_response=$(b/openai thread.run.poll -t "$thread_id" -r "$run_id" | jq)
    status=$(echo "$run_response" | jq -r '.status')
    echo -e "Status: $status"
    [[ "$status" != "in_progress" && "$status" != "queued" ]] && break
    sleep 2
done

# Get the response
last_message=$(b/openai thread.messages.list -t "$thread_id" | jq -r '.messages[0].value')

echo -e "\n 🤖 ${green}ASSISTANT${reset}: $last_message"

while true; do
    read -rp $'\n 🧑 USER: ' question

    # Exit the loop if the user types 'exit'
    if [[ $question == 'exit' ]]; then
        break
    fi

    # Append message to thread and run the assistant again
    response=$(b/openai thread.messages.append -t "$thread_id" -m "$question" | jq)

    run_id=$(b/openai thread.run -t "$thread_id" -a "$assistant" | jq -r .run_id)

    echo -e "\n🌿 Polling for AI response..."

    while true; do
        status=$(b/openai thread.run.poll -t "$thread_id" -r "$run_id" | jq -r '.status')
        [[ "$status" != "in_progress" && "$status" != "queued" ]] && break
        sleep 2
    done

    last_message=$(b/openai thread.messages.list -t "$thread_id" | jq -r '.messages[0].value')

    echo -e "\n 🤖 ${green}ASSISTANT${reset}: $last_message"
done