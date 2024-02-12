#!/bin/bash

# Example input using refined syntax
input="getCurrentWeather|Gets the weather in location|*location:str:The city and state e.g. San Francisco, CA;unit:str:The unit of temperature:[c,f]"

# Parse function name, description, and parameters
IFS='|' read -r function_name description parameters_str <<< "$input"

# Convert parameters string to array
IFS=';' read -r -a parameters <<< "$parameters_str"

# Start constructing JSON
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

# Process each parameter
for param in "${parameters[@]}"; do
    IFS=':' read -r name type param_desc constraints <<< "$param"

    # Check if parameter is required
    if [[ $name == \** ]]; then
        required=true
        name="${name:1}"  # Remove asterisk
        json=$(echo $json | jq --arg n "$name" '.function.parameters.required += [$n]')
    else
        required=false
    fi

    # Handle enum constraint
    if [[ $constraints == [* ]]; then
        enum_values=$(echo "$constraints" | tr -d '[]' | jq -R 'split(",")')
        json=$(echo $json | jq --arg n "$name" --arg t "$type" --arg d "$param_desc" --argjson e "$enum_values" \
            '.function.parameters.properties += {($n): {type: $t, description: $d, enum: $e}}')
    else
        json=$(echo $json | jq --arg n "$name" --arg t "$type" --arg d "$param_desc" \
            '.function.parameters.properties += {($n): {type: $t, description: $d}}')
    fi
done

echo $json | jq .
