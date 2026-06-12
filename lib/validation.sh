#!/bin/bash
validate_file() {
  [ -f "$1" ] || { log_erro "File not found: $1"; return 1; }
}

validate_directory() {
  [ -d "$1" ] || { log_erro "Directory not found: $1"; return 1; }
}