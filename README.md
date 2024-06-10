# ollama-helper-tools

## Introduction

A small collection of tools to help with managing ollama.

## Tools

### ollama-list-models.sh

`ollama-list-models.sh` is a shell script that calls the ollama api and
displays sortable details of the installed models.

#### Example Output

```text
$ ./ollama-list-models --sort size --reverse
Model                       Size  Modified    Param Size  Quant Level
mixtral:latest           24.7GiB  2024-05-13       47.0B  Q4_0
codestral:latest         11.8GiB  2024-05-31       22.2B  Q4_0
gemma:latest              4.7GiB  2024-05-12        9.0B  Q4_0
llava:latest              4.5GiB  2024-06-09        7.0B  Q4_0
llama3:latest             4.4GiB  2024-05-22        8.0B  Q4_0
phi3:latest               2.2GiB  2024-05-12        4.0B  Q4_K_M
```

This is in comparison to the original output from `ollama list`

```text
NAME                         ID              SIZE    MODIFIED
llava:latest                 8dd30f6b0cb1    4.7 GB  16 hours ago
codestral:latest             fcc0019dcee9    12 GB   9 days ago
llama3:latest                365c0bd3c000    4.7 GB  2 weeks ago
mixtral:latest               7708c059a8bb    26 GB   4 weeks ago
phi3:latest                  a2c89ceaed85    2.3 GB  4 weeks ago
gemma:latest                 a72c7f4d0a15    5.0 GB  4 weeks ago
```

#### Requirements / Installation

`ollama-list-models.sh`  requires that the `jq` package (cli json parser) be
installed. (It also requires `bash`, which should be available & probably
already installed on any standard Linux or MacOS system.

##### Debian / Ubuntu

```bash
# Update repositories & install jq
sudo apt update; sudo apt install jq
```

#### Usage

The following is the output of `./ollama-list-models.sh`

```text
ollama-list-models Version 0.1
https://github.com/GeoMaciolek/ollama-helper-scripts

Usage: ./ollama-list-models.sh [option... [value]]

-s, --sort (key)        Sorts by the key provided. Valid keys:
                        name, size, modified, date, param_size, quant_level
-r, --reverse   Reverse-sort the output
-V, --version   Display utility version
-h, --help      Display this information
```

### Other Tools

TBD!

## External Links

- [Ollama Site](https://www.ollama.com/)
- [Ollama Github](https://github.com/ollama/ollama)
- [Open-Webui Site](https://openwebui.com/) (A good general purpose web frontend for **Ollama** and other services like **OpenAI GPT-4**.)

