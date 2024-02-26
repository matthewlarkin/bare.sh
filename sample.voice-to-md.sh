source "$(dirname "${BASH_SOURCE[0]}")/lib/init"

# Define the paths for the temporary WAV file and the final MP3 file
timestamp=$(date +%s)
wav_file="$BARE_DIR/tmp/recorded_$timestamp.wav"
mp3_file="$BARE_DIR/tmp/recorded_$timestamp.mp3"
txt_file="$BARE_DIR/tmp/recorded_$timestamp.txt"

echo "Starting audio recording. Press Enter to stop."

# Start the recording in the background
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    arecord -f cd -t wav "$wav_file" > /dev/null 2>&1 &
    rec_pid=$!
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    which sox &> /dev/null || brew install sox
    sox -d -t wav "$wav_file" > /dev/null 2>&1 &
    rec_pid=$!
else
    # Unknown.
    echo "Unknown OS"
    exit 1
fi

# Wait for an Enter key press, then kill the recording process
read -r -p ""
kill -INT "$rec_pid"

# Proceed with the conversion
which ffmpeg &> /dev/null || { [[ "$OSTYPE" == "darwin"* ]] && brew install ffmpeg; }
ffmpeg -i "$wav_file" "$mp3_file" > /dev/null 2>&1

echo "Audio recording saved as $mp3_file"

echo -e "\n${yellow}Transcribing audio to text.${reset}\n"

response=$(b/openai audio.transcribe -f "$mp3_file" -o "$txt_file" | jq -r .file)

# Check if the transcribe command succeeded
if [[ $? -ne 0 ]]; then
    echo "Failed to transcribe audio"
    exit 1
fi

file_contents=$(cat "$txt_file")

markdown=$(b/openai chat -m "Please respond to this: $file_contents" | jq -r .response)

b/notes add -N 'home' -T "Voice Note" -C "$markdown" -f "voice-note-$timestamp.md" > /dev/null

echo -e "📝 ${green}Note created and saved to your notes store.${reset}"

# Clean up the temporary files
rm "$wav_file" "$mp3_file" "$txt_file"