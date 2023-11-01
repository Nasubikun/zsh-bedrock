CONFIG_DIR="$HOME/.config/zsh-bedrock"
CONFIG_FILE="$CONFIG_DIR/config.json"
# Function to initialize configuration with default values
function initialize_config() {
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
function config_get() {
    local key=$1
    jq -r ".$key // empty" "$CONFIG_FILE"
}
# Function to set a value in the configuration file
function config_set() {
    local key=$1
    local value=$2
    if [[ $key == "LANGS" ]]; then
        jq ".${key} = $value" "$CONFIG_FILE" >"$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    else
        jq ".${key} = \"$value\"" "$CONFIG_FILE" >"$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
}
