#!/bin/bash

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# SCRIPT:        SETUP_TEMPLATE.sh
# USAGE:         bash SETUP_TEMPLATE.sh | ./SETUP_TEMPLATE.sh
# PURPOSE:       Shell script that setups the @TuxTechLab/TuxTechLab-Template-Repo GitHub project template.
#                It detects the user's GitHub username, email and project name,
#                and then prompts for the type of project that it is. All the data can be manually specified using
#                the script optional arguments. For more information, please execute the script with the '--help' flag.
#                After it will customize all the files with the user's data and remove some files and folders,
#                even this own script.
# TITLE:         SETUP_TEMPLATE
# AUTHOR:        @TuxTechLab
# VERSION:       See in CHANGELOG.md or in variable 'SCRIPT_VERSION'.
# NOTES:         This script will auto remove itself, and if you want to rerun it, the user must download
#                it again or do a 'git stash' and revert the changes.
# BASH_VERSION:  5.1.4(1)-release (x86_64-pc-linux-gnu)
# LICENSE:       see in LICENSE (project root) or https://github.com/TuxTechLab/TuxTechLab-Template-Repo/blob/master/LICENSE
# GITHUB:        https://github.com/TuxTechLab/
# REPOSITORY:    https://github.com/TuxTechLab/TuxTechLab-Template-Repo
# ISSUES:        https://github.com/TuxTechLab/TuxTechLab-Template-Repo/issues
# MAIL:          root.tuxtechlab@gmail.com
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

RED='\033[1;31m'                                     # color red
NAME_AND_PROJECT_UNPARSED=$(git ls-remote --get-url) # READ GITHUB USERNAME AND GITHUB PROJECT NAME
NEW_USERNAME=$(echo "$NAME_AND_PROJECT_UNPARSED" | cut -d':' -f 2 | cut -d'/' -f 1)
PROJECT_NAME=$(echo "$NAME_AND_PROJECT_UNPARSED" | cut -d'/' -f 2 | cut -d'.' -f 1)
NEW_EMAIL=$(git config user.email)
TEMP_TEST_OUTPUT=".ignore.test_output.txt"
PROJECT_TYPE="repository" # default value if not specified
will_omit_verification=false
will_omit_commit=false
will_omit_test=false
SCRIPT_VERSION="1.11.8"

FILE_FUNCTION_HELPERS=bin/FUNCTION_HELPERS.sh

if [ ! -f "$FILE_FUNCTION_HELPERS" ]; then # check if the function helpers file is not found
  echo -e "${RED}X Can not find ${FILE_FUNCTION_HELPERS}"
  exit 1 # it will exit if the function helpers file is not found
else
  # shellcheck source=bin/FUNCTION_HELPERS.sh disable=SC1091
  source $FILE_FUNCTION_HELPERS || exit 1 # obtain some global functions and variables, if the file isn't found exit
fi

# Function to display help text
displayHelpTexts() {
    center "${GREEN}SETUP_TEMPLATE.sh - Project Initialization Script${NC}"
    echo -e "\n${BOLD}${GREEN}Usage:${NC} $0 [OPTIONS]\n"
    
    echo -e "${BOLD}Options:${NC}"
    echo -e "  -u, --username=USERNAME    Set GitHub username"
    echo -e "  -e, --email=EMAIL          Set email address (--mail is also accepted)"
    echo -e "  -p, --project=NAME         Set project name"
    echo -e "  -t, --type=TYPE            Set project type (e.g., website, api, cli, etc.)"
    echo -e "  -h, --help                 Show this help message and exit"
    echo -e "  -v, --version              Show version information and exit"
    echo -e "  --omit-verification        Skip verification prompts"
    echo -e "  --omit-commit              Skip automatic commit"
    echo -e "  --omit-tests               Skip running tests"
    
    echo -e "\n${BOLD}Argument Formats:${NC}"
    echo -e "  All these formats are supported for all options:"
    echo -e "  ${CYAN}--option=value${NC}    (e.g., --username=myuser)"
    echo -e "  ${CYAN}--option value${NC}     (e.g., --username myuser)"
    echo -e "  ${CYAN}-o=value${NC}           (e.g., -u=myuser)"
    echo -e "  ${CYAN}-o value${NC}           (e.g., -u myuser)"
    
    echo -e "\n${BOLD}Examples:${NC}"
    echo -e "\n  ${CYAN}Using Long Parameters:${NC}"
    echo -e "  $0 --username=myuser --email=me@example.com --project=myproject --type=website"
    echo -e "  $0 --username myuser --email me@example.com --project myproject --type website"
    
    echo -e "\n  ${CYAN}Using Short Parameters:${NC}"
    echo -e "  $0 -u=myuser -e=me@example.com -p=myproject -t=website"
    echo -e "  $0 -u myuser -e me@example.com -p myproject -t website"
    
    echo -e "\n  ${CYAN}Mixed Formats:${NC}"
    echo -e "  $0 -u myuser --email=me@example.com -p=myproject --type website"
    
    echo -e "\n${BOLD}Note:${NC} For more information, visit ${UPURPLE}https://github.com/TuxTechLab/TuxTechLab-Template-Repo${NC}"
    
    exit 0
}

# Function to parse arguments in both --option=value, -o=value, --option value, and -o value formats
parse_arguments() {
    while [ $# -gt 0 ]; do
        case "$1" in
            # Handle --option=value format
            --*=*)
                arg="$1"
                key="${arg%%=*}"
                value="${arg#*=}"
                shift
                ;;
            # Handle -o=value format
            -?=*)
                arg="$1"
                key="-${arg:0:2}"  # Get -o
                value="${arg#*=}"   # Get the value after =
                shift
                ;;
            # Handle --option value format
            --*)
                key="$1"
                value=""
                # Check if next argument is not another option
                if [ $# -gt 1 ] && [ "${2:0:1}" != "-" ]; then
                    value="$2"
                    shift
                fi
                shift
                ;;
            # Handle -o value format
            -*)
                key="$1"
                value=""
                # If this is a short option with no value, check next arg
                if [ ${#key} -eq 2 ] && [ $# -gt 1 ] && [ "${2:0:1}" != "-" ]; then
                    value="$2"
                    shift
                fi
                shift
                ;;
            # Skip non-option arguments
            *)
                shift
                continue
                ;;
        esac

        # Process the key-value pair
        case "$key" in
            -u|--user|--username|--name)
                NEW_USERNAME="$value"
                ;;
            -e|--email|--mail)
                NEW_EMAIL="$value"
                ;;
            -p|--project|--project-name|--project_name|--projectName)
                PROJECT_NAME="$value"
                ;;
            -t|--type|--project_type|--projectType)
                PROJECT_TYPE="$value"
                ;;
            -h|--help|--info|--information)
                displayHelpTexts
                exit 0
                ;;
            -v|--version)
                echo -e "${GREEN}Version: $SCRIPT_VERSION${NC}"
                exit 0
                ;;
            --omit-verification)
                will_omit_verification=true
                choice="y"
                ;;
            --omit-commit)
                will_omit_commit=true
                ;;
            --omit-test-check|--omit-tests-check|--omit-tests)
                will_omit_test=true
                ;;
            -o|--omit|--omit-commit-and-confirmation)
                echo -e "${BBLUE}Note:${NC} The arguments '--omit-commit-and-confirmation', '-o' and '--omit' are ${YELLOW}deprecated${NC}. Use '--omit-verification' and/or '--omit-commit' instead."
                will_omit_verification=true
                will_omit_commit=true
                choice="y"
                ;;
            -*)
                echo -e "${RED}Error: Unknown option: $key${NC}" >&2
                displayHelpTexts
                exit 1
                ;;
        esac
    done
}

# Parse the command line arguments
parse_arguments "$@"

echo -e "Thanks for using ${GREEN}@TuxTechLab/TuxTechLab-Template-Repo${NC}"
echo -e "Read all the documentation carefully before you continue executing this script: ${UPURPLE}https://github.com/TuxTechLab/TuxTechLab-Template-Repo${NC}\n"

bash tests/TESTS_RUNNER.sh >/dev/null 2>&1 # PERFORM the TESTS

if [ "$?" -eq 1 ] && [ $will_omit_test = false ]; then # if when running the tests any error was found
  rm "$TEMP_TEST_OUTPUT" 2>/dev/null || :
  displayTestErrorTexts
  exit 1
fi

rm "$TEMP_TEST_OUTPUT" 2>/dev/null || :

if [ "$PROJECT_TYPE" = "repository" ]; then # if the project's type has not been manually specified
  read -p "Enter $(echo -e "$BBLUE""what your project is""$NC") (program/extension/API/web/CLI tool/backend/frontend/scrapper/automation tool/etc): " PROJECT_TYPE
fi

if [ $will_omit_verification = false ]; then # if the ignore flag has not been manually specified
  read -p "Is this data correct: username \"$(echo -e "$GREEN""$NEW_USERNAME""$NC")\", email: \"$(echo -e "$GREEN""$NEW_EMAIL""$NC")\", project name: \"$(echo -e "$GREEN""$PROJECT_NAME""$NC")\", of type: \"$(echo -e "$GREEN""$PROJECT_TYPE""$NC")\" (y/n)? " choice
fi

# confirm that the data is correct
case "$choice" in
y | Y)
  center "Setting everything up for you ;)"

  # replace the username and email
  find .github/ -type f -name "*" -print0 | xargs -0 sed -i "s/TuxTechLab/${NEW_USERNAME}/g"
  find .github/ -type f -name "*" -print0 | xargs -0 sed -i "s/root.tuxtechlab@gmail.com/${NEW_EMAIL}/g"
  find .github/ -type f -name "*" -print0 | xargs -0 sed -i "s/project-template/${PROJECT_NAME}/g"
  find .gitignore -type f -name "*" -print0 | xargs -0 sed -i "s/TuxTechLab\/project-template/${NEW_USERNAME}\/${PROJECT_NAME}/g"

  rm LICENSE 2>/dev/null || :                                 # remove the license
  rm -r bin/ 2>/dev/null || :                                 # remove the bin folder
  rm -r tests/ 2>/dev/null || :                               # remove the tests folder
  rm -r .github/workflows/ 2>/dev/null || :                   # remove the workflow folder
  writeREADME                                                 # write the new README.md
  writeCHANGELOG                                              # write the basic structure of the CHANGELOG.md
  echo -e "# add your own funding links" >.github/FUNDING.yml # remove author's custom funding links

  if [ "$will_omit_commit" = false ]; then
    # Only perform git operations if --omit-commit is NOT set
    git add CHANGELOG.md README.md .gitignore .github SETUP_TEMPLATE.sh LICENSE bin tests
    git -c color.status=always status | less -REX
    echo -e "Committing the changes for you :)\n"
    git commit -m "📝 Set up '@TuxTechLab/TuxTechLab-Template-Repo' template: Personalized files by executing the SETUP_TEMPLATE.sh script.🚀"
    echo -e "\nRemember to review every file and customize it as you like.\nYou are ready to start your brand new awesome project🚀🚀."
  else
    echo -e "\n${YELLOW}Changes have been made but not committed (--omit-commit was specified).${NC}"
    echo -e "Review the changes and commit them manually when ready.\n"
  fi

  # self remove this script
  rm -- "$0" 2>/dev/null || :
  ;;
n | N)
  echo -e "\nIf your username, project name or email were NOT right, you can manually change them. Read how to do it with the script's help: ${UPURPLE}bash SETUP_TEMPLATE.sh --help${NC}\n"
  ;;
*) echo -e "${RED}X Invalid option${NC}" ;;
esac

exit 0
