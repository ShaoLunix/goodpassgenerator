#!/bin/bash

#=======================================================================================#
# Versions
# [2019-08-11] [1.0] [Stéphane-Hervé] First version
#=======================================================================================#
VER=1.0

# strict mode
set -o nounset

myscript="goodpassgenerator"
mycontact="https://github.com/ShaoLunix/goodpassgenerator/issues"



#====================#
# Default parameters #
#====================#
defaultlength=15
minimlength=6
number=1
complexity="alnum,spec"
# Definition of the variables
count=""
linenumber=""
length=$defaultlength
islengthmentioned=false
remaininglength=$(($length - $minimlength))
alphaseries=""
lcseries=""
ucseries=""
digitseries=""
specseries=""
alphaletters=""
lcletters=""
ucletters=""
digits=""
specialchars=""



#============#
# FUNCTIONS #
#============#

# Abnormal exit
abnormalExit()
{
    echo "$myscript -- End -- Failed"
    exit 2
}

# Aborting the script because of a wrong parameter
usage()
{
    echo "Usage: $myscript [-c] [-h] [-l LENGTH] [-n NUMBER] [-v] [-x COMPLEXITY]"
    echo "For more information on how to use the script, type : < $myscript -h >"
    echo "$myscript -- End -- failed"
    exit 1
}

# display the help of this script
displayhelp()
{
    echo "Syntax : $myscript [OPTION ...]"
    echo "Generate a random password based on the values passed with the arguments -lnx."
    echo
    echo "With no option, the command returns a 6 characters password that contains 2 alphabetic (1 lower case + 1 upper case), 2 digital and 2 special characters."
    echo
    echo "$myscript [-c] [-l LENGTH] [-n NUMBER] [-x COMPLEXITY]"
    echo "$myscript [-h]"
    echo "$myscript [-v]"
    echo
    echo "  -c :        counter of passwords. It starts every line with its number."
    echo "  -h :        display the help."
    echo "  -l :        length of the password to generate."
    echo "              If this option isnot used, then a $defaultlength characters length is applied."
    echo "              If the length is too short, then a minimum of $minimlength characters is applied."
    echo "  -n :        number of passwords to generate."
    echo "  -v :        this script version."
    echo "  -x :        complexity of the password."
    echo "              The options are :"
    echo "              - alpha : alphabetic letters allowed (upper and lower cases)"
    echo "              - numeric or num or digit : digits allowed"
    echo "              - alnum : alphanumeric characters allowed"
    echo "              - spec or special : only special characters allowed"
    echo "              - upper : upper case characters allowed"
    echo "              - lower : lower case characters allowed"
    echo "              - alnumspec : alphanumeric and special characters allowed"
    echo "              These above options can be mixed :"
    echo "              « -x alphadigit », « -x alphanum » or « -x alphanumeric » generate alphanumeric characters"
    echo "              « -x alphaspec » generates alphabetic and special characters"
    echo "              If only « upper » is passed then only upper case characters are generated."
    echo "              If only « lower » is passed then only lower case characters are generated."
    echo "              If only « numeric », « num » or « digit » is passed then only digital characters are generated."
    echo "              If only « spec » or « special » is passed then only special characters are generated."
    echo
    echo "Although a minimum of $minimlength characters length can be applied (due to some online services requiring only $minimlength characters codes), it is highly recommended to use a minimum of 13 characters long password. In that respect, this command uses a $defaultlength characters password per default. Furthermore, when the password isnot too short, then this command returns one mixing at least 2 characters of the following : upper case, lower case, digits and special."
    echo
    echo "Exit status : "
    echo " 0 = success"
    echo " 1 = failure due to wrong parameters"
    echo " 2 = abnormal exit"
    echo
    echo "To inform about the problems : $mycontact."
    exit
}

# management of exit signals
trap 'abnormalExit' 1 2 3 4 15

# Flags
# -c : count the number of passwords
# -h : display the help
# -l : length of the password to generate
# -n : number of passwords to generate
# -v : this script version
# -x : complexity of the password
#       options can be mixed : they have then to be quoted and separated with a comma with no space
#       - alpha : alphabetic letters allowed
#       - numeric or num or digit : digits allowed
#       - alnum : alphanumeric characters allowed
#       - spec or special : only special characters allowed
#       - upper : upper case characters allowed
#       - lower : lower case characters allowed
#       - alnumspec : alphanumeric and special characters allowed
while getopts "chl:n:vx:" option
do
    case "$option" in
        c)
            count=true
            ;;
        h)
            displayhelp
            exit
            ;;
        l)
            length=${OPTARG}
            islengthmentioned=true
            # The length can only be superior or equal to the defined minimum length
            if [[ $length -lt $minimlength ]]
            then
                length=$minimlength
            fi
            remaininglength=$(($length - $minimlength))
            ;;
        n)
            number=${OPTARG}
            ;;
        v)
            echo "$myscript -- Version $VER -- Start"
            date
            exit
            ;;
        x)
            complexity=${OPTARG}
            ;;
        \? ) # For invalid option
            usage
            ;;
    esac
done

# Generation of the password(s)
for i in `seq 1 $number`
do
    # ***
    # Random generation of lower and upper case letters, digits and special characters (2 of each)
    # ***
    # Alphabetic characters
    if [[ "$complexity" == *"alpha"* ]] || [[ "$complexity" == *"alnum"* ]] || [[ "$complexity" == *"upper"* ]] || [[ "$complexity" == *"lower"* ]]
    then
        if [[ "$complexity" == *"alpha"* ]] || [[ "$complexity" == *"alnum"* ]]
        then
            if [[ "$length" -lt 8 ]]
            then
                alphaseries='a-zA-Z'
                alphaletters=$(< /dev/urandom tr -dc "$alphaseries" | head -c"2" | tr -d '\n')
            else
                alphaseries='a-z'
                alphaletters=$(< /dev/urandom tr -dc "$alphaseries" | head -c"2" | tr -d '\n')
                alphaseries='A-Z'
                alphaletters="$alphaletters"$(< /dev/urandom tr -dc "$alphaseries" | head -c"2" | tr -d '\n')
                # As 2x 2 characters are passed in one execution, then
                # 2 are taken off the remaining length to respect the password length
                remaininglength=$(($remaininglength - 2))
            fi
        fi
        if [[ "$complexity" == *"upper"* ]]
        then
            ucseries='A-Z'
            ucletters=$(< /dev/urandom tr -dc "$ucseries" | head -c"2" | tr -d '\n')
        fi
        if [[ "$complexity" == *"lower"* ]]
        then
            lcseries='a-z'
            lcletters=$(< /dev/urandom tr -dc "$lcseries" | head -c"2" | tr -d '\n')
        fi
    else
        remaininglength=$(($remaininglength + 2))
    fi
    # Digit characters
    if [[ "$complexity" == *"num"* ]] || [[ "$complexity" == *"digit"* ]]
    then
        digitseries='0-9'
        digits=$(< /dev/urandom tr -dc "$digitseries" | head -c"2" | tr -d '\n')
    else
        remaininglength=$(($remaininglength + 2))
    fi
    # Special characters
    if [[ "$complexity" == *"spec"* ]]
    then
        specseries='!\"#\$%&()*+,-\./:;<=>?@[]^_{|}~'
        specialchars=$(< /dev/urandom tr -dc "$specseries" | head -c"2" | tr -d '\n')
    else
        remaininglength=$(($remaininglength + 2))
    fi

    # Additional random characters to reach the requested length
    if [[ $remaininglength -gt 0 ]]
    then
        additionalchars=$(< /dev/urandom tr -dc "$alphaseries""$ucseries""$lcseries""$digitseries""$specseries" | head -c"$remaininglength" | tr -d '\n')
    else
        additionalchars=""
    fi

    # Concatenation and shuffling of the randomly generated words
    password=$(echo "$alphaletters""$lcletters""$ucletters""$digits""$specialchars""$additionalchars" | fold -w1 | shuf | tr -d '\n')

    if [[ "$count" = true ]]
    then
        linenumber="$i : "
    fi
    echo "$linenumber""$password"
    remaininglength=$(($length - $minimlength))
done
echo

exit
