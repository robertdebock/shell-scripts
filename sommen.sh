#!/bin/bash

echo "Hoe moeilijk wil je het maken vandaag?"
echo "Kies: makkelijk, gemiddeld moeilijk of gruwelijk."

read -r level

case "${level}" in
  makkelijk)
    until=10
  ;;
  gemiddeld)
    until=25
  ;;
  moeilijk)
    until=100
  ;;
  gruwelijk)
    until=1000
  ;;
  *)
    echo "Je koos: ${level}, maar dat bestaat niet."
    echo "Kies: makkelijk, gemiddeld, moeilijk of gruwelijk."
    exit 1
  ;;
esac

goed() {
  array[0]="Goed, lekker bezig."
  array[1]="Goed, netjes man."
  array[2]="Goed, perfect zelfs."
  array[3]="Goed, mooi antwoord ook."
  array[4]="Goed, kanjer."
  array[5]="Goed, en die was lastig."
  array[6]="Goed, hoe dan?"
  array[7]="Goed, ziek man."
  array[8]="Goed, Einstein is er niets bij."
  array[9]="Goed, ga door bro."
  array[10]="Goed, ez bozo, plus ratio."
  array[11]="Goed, lmfao."
  array[12]="Goed, gg."

  size=${#array[@]}
  index=$((RANDOM % size))
  echo "${array[$index]}"
}

min() {
  left=$((1+ RANDOM % until))
  right=$((1+ RANDOM % left))
  
  correct="$((left-right))"

  printf "%s - %s = " "${left}" "${right}"
  
  read -r answer
  
  if [ "${answer}" = "${correct}" ] ; then
    goed
  else
    printf "Dat klopt niet, het antwoord was %s.\n" "${correct}"
  fi
}

plus() {
  left=$((1+ RANDOM % until))
  right=$((1+ RANDOM % left))
  
  correct="$((left+right))"

  printf "%s + %s = " "${left}" "${right}"
  
  read -r answer
  
  if [ "${answer}" = "${correct}" ] ; then
    goed
  else
    printf "Dat klopt niet, het antwoord was %s.\n" "${correct}"
  fi
}

keer() {
  left=$((1+ RANDOM % until))
  right=$((1+ RANDOM % left))
  
  correct="$((left*right))"

  printf "%s * %s = " "${left}" "${right}"
  
  read -r answer
  
  if [ "${answer}" = "${correct}" ] ; then
    goed
  else
    printf "Dat klopt niet, het antwoord was %s.\n" "${correct}"
  fi
}

delen() {
  left=$((1+ RANDOM % until))
  right=$((1+ RANDOM % left))
  until [ $(( left%right )) == 0 ] ; do
    left=$((1+ RANDOM % until))
    right=$((1+ RANDOM % left))
  done
  
  correct="$((left/right))"

  printf "%s / %s = " "${left}" "${right}"
  
  read -r answer
  
  if [ "${answer}" = "${correct}" ] ; then
    goed
  else
    printf "Dat klopt niet, het antwoord was %s\n". "${correct}"

  fi
}

while true ; do
  min
  plus
  keer
  delen
done
