#!/bin/bash

# --- Global Variables ---
# 儲存每個函數所需環境變數的關聯陣列
declare -A REQUIRED_ENV_VARS
# 儲存所有生成函數名稱的陣列
declare -a FUNCTION_NAMES_ARRAY
# 輸入 JSON 檔案名稱 (例如 ex1.json)
JSON_CONFIG_FILE=""
# 模組名稱 (例如 ex1)
MODULE_NAME=""
# 乾跑模式標誌 (如果請求乾跑，則為 true)
DRY_RUN_MODE=false

# --- Helper Functions ---

# 檢查 jq 是否已安裝
check_jq_installed() {
  if ! command -v jq &> /dev/null; then
    echo "錯誤: 'jq' 未安裝。請先安裝 'jq' (例如: sudo apt-get install jq 或 brew install jq)。" >&2
    exit 1
  fi
}

# 驗證輸入的 JSON 檔案
validate_json_file() {
  if [ -z "$JSON_CONFIG_FILE" ]; then
    echo "請提供 JSON 檔案名稱 (模組名稱) 作為第一個參數。" >&2
    echo "用法: $0 <module_name> [dryrun]" >&2
    exit 1
  fi

  if [ ! -f "$JSON_CONFIG_FILE" ]; then
    echo "錯誤: 找不到指定的 JSON 檔案 '$JSON_CONFIG_FILE'。" >&2
    exit 1
  fi
}

# --- Core Logic Functions ---

# 解析 JSON 並生成個別的 curl 函數
# 解析 JSON 並生成個別的 curl 函數
parse_json_and_generate_functions() {
  echo "正在解析 '$JSON_CONFIG_FILE' 並生成 Bash 函數..."

  while read -r entry; do
    local name=$(echo "$entry" | jq -r '.name // empty')
    local command=$(echo "$entry" | jq -r '.command // "curl"')
    local args_array_string=$(echo "$entry" | jq -r '.argument[] // empty')
    local variables_array=$(echo "$entry" | jq -r '.variable[] // empty')

    if [ -z "$name" ]; then
      echo "警告: 偵測到缺少 'name' 欄位的物件。將跳過此項目。" >&2
      continue
    fi

    local full_func_name="${MODULE_NAME}_${name}"
    FUNCTION_NAMES_ARRAY+=("$full_func_name")
    echo "  正在生成函數: $full_func_name"

    echo "$full_func_name() {" >> "$OUTPUT_SCRIPT"

    readarray -t var_names <<< "$variables_array"
    if [ ${#var_names[@]} -gt 0 ]; then
      local arg_counter=1
      for i in "${!var_names[@]}"; do
        echo "  local ${var_names[$i]}=\$${arg_counter}" >> "$OUTPUT_SCRIPT"
        ((arg_counter++))
      done
    fi

    # --- 關鍵修正開始 ---
    local curl_command_lines=("${command}") # 初始化命令的第一部分

    readarray -t args <<< "$args_array_string"
    local current_func_env_vars=""

    for i in "${!args[@]}"; do
      local arg="${args[$i]}"

      # 檢查參數中是否存在環境變數 (排除函數參數)
      local found_vars=$(echo "$arg" | grep -oE '\$\{[A-Za-z_][A-Za-z0-9_]*\}' | sed 's/\${//;s/}//g' | grep -vFf <(printf "%s\n" "${var_names[@]}" 2>/dev/null) )
      if [ -n "$found_vars" ]; then
        for var_name in $found_vars; do
          if ! [[ " $current_func_env_vars " =~ " $var_name " ]]; then
            current_func_env_vars+=" $var_name"
          fi
        done
      fi

      # 將每個參數作為獨立的字串加入陣列，並確保適當的引用
      curl_command_lines+=("\"$arg\"")
    done

    # 組合最終要寫入腳本的指令字串
    if $DRY_RUN_MODE; then
      echo "  echo \"乾跑模式執行 $full_func_name:\"" >> "$OUTPUT_SCRIPT"
      echo "  echo \"$(printf "%s " "${curl_command_lines[@]}")\"" >> "$OUTPUT_SCRIPT"
    else
      # 使用單個反斜線和換行符，實現 Bash 的多行指令
      # 這裡的 "printf '%s \\\n    ' "${curl_command_lines[@]}" | sed '$s/ \\\n    //'" 會處理：
      # 1. 將所有行用 " \n    " 分隔
      # 2. 移除最後一個多餘的 " \n    "
      # 結果是每個參數都會換行並縮排，最後一個參數後面不會有換行。
      printf '%s \\\n    ' "${curl_command_lines[@]}" | sed '$s/ \\\n    //' >> "$OUTPUT_SCRIPT"
      echo "" >> "$OUTPUT_SCRIPT" # 確保最後有一個換行，以結束指令
    fi
    # --- 關鍵修正結束 ---

    echo "}" >> "$OUTPUT_SCRIPT"
    echo "" >> "$OUTPUT_SCRIPT"

    REQUIRED_ENV_VARS["$full_func_name"]="${current_func_env_vars}"
  done < <(jq -c '.[]' "$JSON_CONFIG_FILE")
}


# 生成 'about' 函數
generate_about_function() {
  local full_func_name="${MODULE_NAME}_about"
  echo "  正在生成 '${full_func_name}' 函數..."
  echo "$full_func_name() {" >> "$OUTPUT_SCRIPT"
  echo "  echo \"模組 '${MODULE_NAME}' 的可用指令 (函數) 及其所需環境變數 (在呼叫函數前設定):\"" >> "$OUTPUT_SCRIPT"
  echo "  echo \"\"" >> "$OUTPUT_SCRIPT"

  if [ ${#REQUIRED_ENV_VARS[@]} -eq 0 ]; then
    echo "  echo \"尚無指令資訊可顯示。請確認 JSON 檔案中定義了指令。\"" >> "$OUTPUT_SCRIPT"
  else
    for func_name in "${!REQUIRED_ENV_VARS[@]}"; do
      if [[ "$func_name" == "${MODULE_NAME}_"* ]]; then
        local env_vars="${REQUIRED_ENV_VARS[$func_name]}"
        echo "  echo \"---\"" >> "$OUTPUT_SCRIPT"
        echo "  echo \"指令: '$func_name'\"" >> "$OUTPUT_SCRIPT"
        if [ -n "$env_vars" ]; then
          local sorted_vars=$(echo "$env_vars" | xargs -n1 | sort -u | xargs)
          echo "  echo \"所需環境變數:\"" >> "$OUTPUT_SCRIPT"
          for var in $sorted_vars; do
            echo "  echo \"  - $var\"" >> "$OUTPUT_SCRIPT"
          done
        else
          echo "  echo \"不需要額外的環境變數。\"" >> "$OUTPUT_SCRIPT"
        fi
      fi
    done
  fi
  echo "  echo \"\"" >> "$OUTPUT_SCRIPT"
  echo "  echo \"若要查看函數接受的參數，請使用 'type <function_name>'。\"" >> "$OUTPUT_SCRIPT"
  echo "}" >> "$OUTPUT_SCRIPT"
  echo "" >> "$OUTPUT_SCRIPT"
}

# 生成 'list' 函數
generate_list_function() {
  local full_func_name="${MODULE_NAME}_list"
  echo "  正在生成 '${full_func_name}' 函數..."
  echo "$full_func_name() {" >> "$OUTPUT_SCRIPT"
  echo "  echo \"模組 '${MODULE_NAME}' 的可用指令 (函數) 列表:\"" >> "$OUTPUT_SCRIPT"
  echo "  echo \"\"" >> "$OUTPUT_SCRIPT"

  if [ ${#FUNCTION_NAMES_ARRAY[@]} -eq 0 ]; then
    echo "  echo \"尚無可用指令。請確認 JSON 檔案中定義了指令。\"" >> "$OUTPUT_SCRIPT"
  else
    # Corrected: Directly echo the function names from the array,
    # ensuring they are treated as literal strings within the generated function.
    # We sort them before iterating to print them in sorted order.
    local sorted_func_names=$(printf "%s\n" "${FUNCTION_NAMES_ARRAY[@]}" | sort)
    while IFS= read -r f_name; do
      if [[ "$f_name" == "${MODULE_NAME}_"* ]]; then
        echo "  echo \"  $f_name\"" >> "$OUTPUT_SCRIPT" # Add "echo" and quotes around "$f_name" to print it literally
      fi
    done <<< "$sorted_func_names" # Use here-string for input to avoid subshell
  fi
  echo "  echo \"\"" >> "$OUTPUT_SCRIPT"
  echo "  echo \"使用 '${MODULE_NAME}_about' 函數查看每個指令的詳細資訊及所需環境變數。\"。" >> "$OUTPUT_SCRIPT"
  echo "}" >> "$OUTPUT_SCRIPT"
  echo "" >> "$OUTPUT_SCRIPT"
}

# --- Main Execution ---

main() {
  JSON_CONFIG_FILE=$1
  MODULE_NAME=${JSON_CONFIG_FILE%%.json}
  MODULE_NAME=${MODULE_NAME#**/}
  OUTPUT_SCRIPT="${MODULE_NAME}.sh"

  if [[ "$2" == "dryrun" ]]; then
    DRY_RUN_MODE=true
    OUTPUT_SCRIPT="${MODULE_NAME}_dryrun.sh"
  fi

  check_jq_installed
  validate_json_file

  echo "#!/bin/bash" > "$OUTPUT_SCRIPT"
  echo "# This script contains Bash functions generated from $JSON_CONFIG_FILE" >> "$OUTPUT_SCRIPT"
  if $DRY_RUN_MODE; then
    echo "# This version is for DRY RUN ONLY. Commands will be printed, not executed." >> "$OUTPUT_SCRIPT"
  fi
  echo "# It includes '${MODULE_NAME}_about' to list required environment variables, and '${MODULE_NAME}_list' to show available functions." >> "$OUTPUT_SCRIPT"
  echo "" >> "$OUTPUT_SCRIPT"

  parse_json_and_generate_functions

  generate_about_function
  generate_list_function

  echo ""
  echo "---"
  echo "Bash 函數已為模組 '${MODULE_NAME}' 生成至 '$OUTPUT_SCRIPT'。"
  echo "您可以使用以下指令載入這些函數："
  echo "  source $OUTPUT_SCRIPT"
  echo ""
  echo "接著，呼叫 '${MODULE_NAME}_list' 函數以查看可用指令："
  echo "  ${MODULE_NAME}_list"
  echo ""
  echo "呼叫 '${MODULE_NAME}_about' 函數以取得詳細資訊和所需變數："
  echo "  ${MODULE_NAME}_about"
  echo "---"
}

main "$@"
