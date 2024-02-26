source "$(dirname "${BASH_SOURCE[0]}")/lib/init"

# Define the paths for the temporary WAV file and the final MP3 file
timestamp=$(date +%s)
wav_file="$BARE_DIR/var/recorded_$timestamp.wav"
mp3_file="$BARE_DIR/tmp/recorded_$timestamp.mp3"

echo "Starting audio recording. Press Ctrl+C to stop."

# Start the recording in the background
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    arecord -f cd -t wav "$wav_file" > /dev/null 2>&1 &
    rec_pid=$!
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    which sox &> /dev/null || brew install sox
    ( trap 'exit' INT; sox -d -t wav "$wav_file" > /dev/null 2>&1 & wait )
else
    # Unknown.
    echo "Unknown OS"
    exit 1
fi

# Wait for the user to press Ctrl+C, then kill the recording process
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    trap 'kill $rec_pid' INT
    wait $rec_pid
    trap - INT
fi

# Proceed with the conversion
which ffmpeg &> /dev/null || { [[ "$OSTYPE" == "darwin"* ]] && brew install ffmpeg; }
ffmpeg -i "$wav_file" "$mp3_file" > /dev/null 2>&1

echo "Audio recording saved as $mp3_file"

echo "Transcribing audio to text."

response=$(b/openai audio.transcribe -f "$mp3_file" -o "$BARE_DIR/tmp/recorded_$timestamp.txt" | jq -r .file)

file_contents=$(cat "$BARE_DIR/tmp/recorded_$timestamp.txt")

markdown=$(b/openai chat -m "Please respond to this: $file_contents" | jq -r .response)

b/notes add -N 'home' -T "Voice Note" -C "$markdown" -f "voice-note-$timestamp.md" > /dev/null

echo -e "📝 ${green}Note created and saved to your notes store.${reset}"

cat "$BARE_NOTES_DIR/home/voice-note-$timestamp.md"