CONFIG_DIR="$HOME/.config/zsh-bedrock"
CONFIG_FILE="$CONFIG_DIR/config.json"
# Function to initialize configuration with default values
function bedrock-zsh-initialize_config() {
    mkdir -p "$CONFIG_DIR"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat >"$CONFIG_FILE" <<-'EOF'
{
    "MODEL_ID": "anthropic.claude-v2",
    "LANGS": ["Japanese", "English"]
}
EOF
        echo "Configuration initialized with default values."
    fi
}
# Function to read a value from the configuration file
function bedrock-zsh-config_get() {
    local key=$1
    jq -r ".$key // empty" "$CONFIG_FILE"
}
# Function to set a value in the configuration file
function bedrock-zsh-config_set() {
    local key=$1
    local value=$2
    if [[ $key == "LANGS" ]]; then
        jq ".${key} = $value" "$CONFIG_FILE" >"$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    else
        jq ".${key} = \"$value\"" "$CONFIG_FILE" >"$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
}

# Define allowed keys
declare -A ALLOWED_KEYS
ALLOWED_KEYS=(
    [AWS_REGION]=1
    [MODEL_ID]=1
    [ENDPOINT_URL]=1
    [LANGS]=1
)

# Helper function to create the body string
function bedrock-zsh-build_body() {
    local custom_prompt=$1
    local template=$2
    local body=$(printf "$template" "$custom_prompt")
    local escaped_body=${body//\\n/\\\\n}
    echo "{\\\"prompt\\\":\\\"$escaped_body\\\",\\\"max_tokens_to_sample\\\":300,\\\"temperature\\\":0.8,\\\"top_k\\\":250,\\\"top_p\\\":0.999,\\\"stop_sequences\\\":[\\\"\\\\n\\\\nHuman:\\\"],\\\"anthropic_version\\\":\\\"bedrock-2023-05-31\\\"}"
}
# Function to generate the body of the command with a raw template and a custom prompt
function bedrock-zsh-raw_prompt() {
    local custom_prompt=$1
    local template="\\\\n\\\\nHuman: %s\\\\n\\\\nAssistant: "
    bedrock-zsh-build_body "$custom_prompt" "$template"
}
# Function to generate the body of the command with a translation template and a custom prompt
function bedrock-zsh-translate_prompt() {
    local custom_prompt=$1
    local langs=$(bedrock-zsh-config_get LANGS | jq -r '.[]')
    local lang1=$(echo "$langs" | head -1)
    local lang2=$(echo "$langs" | tail -1)
    local template="\\\\n\\\\nHuman: Please translate the <sentence>. If $lang1 is passed, translate to $lang2, if $lang2 is passed translate to $lang1. NEVER output anything other than the translation. <sentence>%s</sentence>\\\\n\\\\nAssistant: "
    bedrock-zsh-build_body "$custom_prompt" "$template"
}
function bedrock-zsh-invoke_bedrock() {
    local body=$1
    local AWS_REGION=$(bedrock-zsh-config_get AWS_REGION)
    local MODEL_ID=$(bedrock-zsh-config_get MODEL_ID)
    local ENDPOINT_URL=$(bedrock-zsh-config_get ENDPOINT_URL)
    # Build the command
    local cmd="aws bedrock-runtime invoke-model"
    [[ -n $AWS_REGION ]] && cmd+=" --region $AWS_REGION"
    [[ -n $MODEL_ID ]] && cmd+=" --model-id $MODEL_ID" || cmd+=" --model-id anthropic.claude-v2"
    [[ -n $ENDPOINT_URL ]] && cmd+=" --endpoint-url $ENDPOINT_URL"
    cmd+=" --content-type application/json"
    cmd+=" --accept application/json"
    cmd+=" --body \"$body\""
    cmd+=" /dev/stdout"
    cmd+=" --cli-binary-format raw-in-base64-out | jq -r '.completion // empty'"
    # Evaluate the command
    eval $cmd
}

function bedrock-zsh-brk_internal() {
    if [[ $1 == "-c" ]]; then
        if [[ -n ${ALLOWED_KEYS[$2]} ]]; then
            if [[ $2 == "LANGS" ]]; then
                if [[ $(echo "$3" | jq '. | length') -eq 2 ]]; then
                    bedrock-zsh-config_set "$2" "$3"
                    echo "Configuration updated: $2 = $3"
                else
                    echo "Error: LANGS array must have exactly 2 elements." >&2
                    return 1
                fi
            else
                bedrock-zsh-config_set "$2" "$3"
                echo "Configuration updated: $2 = $3"
            fi
        else
            echo "Error: Key $2 is not an allowed key." >&2
            return 1
        fi
        return
    fi
    # Default to raw prompt mode
    local mode=bedrock-zsh-raw_prompt
    # Check for -t option
    if [[ $1 == "-t" ]]; then
        mode=bedrock-zsh-translate_prompt
        shift # Remove the -t argument
    fi
    local prompt="$*" # Capture all remaining args as a single string
    # Get the body string from the appropriate function based on mode
    local body=$($mode "$prompt")
    bedrock-zsh-invoke_bedrock "$body"
}
bedrock-zsh-initialize_config
alias brk='noglob bedrock-zsh-brk_internal'
