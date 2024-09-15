#!/bin/bash
clear
if [[ -f .savefile ]]; then
	name=$(cat .savefile | awk '{print NR" "$0}' | grep -E '^1' | awk '{print $2}')
	echo -e "\nWelcome back $name!"
	read
	score=$(cat .savefile | grep $name | awk '{print $2}')
else
	echo -e "\nPlease enter your name"
	read name
	echo -e "\nYour name is $name"
	score=500
	read 
fi

echo "let's play some blackjack $name"
sleep 2

#initial variables
inMenu=true
cards=(A 2 3 4 5 6 7 8 9 10 J Q K)

blackjack () { 
	betting=true
	while $betting; do
		clear
		echo -e "\nYou have $score monies to bet, please type your bet: "
		read bet
		if [ $bet -gt $score ]; then
			echo -e "\nThat's too much!"
			read -s
		elif [ $bet -le 0 ]; then
			echo -e "\nObviously you can't bet nothing, try again"
			read -s
		else 
			echo -e "\nYour bet is $bet!"
			sleep 3
			betting=false
		fi
	done

	lost () {
		echo -e "\nYou lost $bet monies"
		let score-=$bet
	}
	won () {
		echo -e "\nYou won $bet monies!"
		let score+=$bet
	}

	yourCards=(${cards[$RANDOM % 13]} ${cards[$RANDOM % 13]})
	dealerCards=(${cards[$RANDOM % 13]} ${cards[$RANDOM % 13]})
	playing=true
	printCards () {
		echo -e "\nYour cards are: ${yourCards[*]}"
		echo -e "Dealer cards are: ${dealerCards[*]}\n"
	}
	getyoursum () {
		yourSum=0
                youHaveA=false
                for i in ${yourCards[*]}; do {
                        if [[ $i =~ [JQK] ]]; then
                                let yourSum+=10
                        elif [[ $i == A ]]; then
                                youHaveA=true
                        else
                                let yourSum+=$i
                        fi
                } done
                if $youHaveA; then
                        for q in ${yourCards[*]}; do
                                if [[ $q == A ]]; then
                                        declare -i tempUSum=$yourSum+11
                                        if [[ $tempUSum -le 21 ]]; then
                                                let yourSum+=11
                                        else
                                                let yourSum++
                                        fi
                                fi
                        done
                fi
	}
	getdealersum () {
		dealerSum=0
                dealerHasA=false
                for j in ${dealerCards[*]}; do {
                	if [[ $j =~ [JQK] ]]; then
                        	let dealerSum+=10
                        elif [[ $j == A ]]; then
                                dealerHasA=true
                        else
                                let dealerSum+=$j
                        fi
                } done
                if $dealerHasA; then
                        for k in ${dealerCards[*]}; do
                        	if [[ $k == A ]]; then
                                	declare -i tempDSum=$dealerSum+11
                                        if [[ $tempDSum -le 21 ]]; then
                                        	let dealerSum+=11
                                        else
                                                let dealerSum++
                                        fi
                                fi
                        done
                fi
	}
	whoWon () {
		getyoursum
		getdealersum
		while [[ $yourSum -gt $dealerSum ]] && [[ $yourSum -le 21 ]]; do
			echo -e "\nThe dealer hits!"
			dealerCards+=(${cards[$RANDOM % 13]})
			sleep 2
			printCards
			sleep 2
			getdealersum
		done
		if [[ $dealerSum -gt 21 ]] && [[ $yourSum -le 21 ]]; then
			echo -e "\nDealer busted! you won!"
			won
		elif [[ $yourSum -gt 21 ]]; then
			echo -e "\nYou busted! Sucks to suck :("
			lost
		elif [[ $yourSum -lt $dealerSum ]]; then 
			echo -e "\nYou lost! Better luck next time!"
			lost
		elif [[ $yourSum -eq $dealerSum ]]; then
			echo -e "\nDealer automatically wins ties! Sorry buddy"
			lost
		elif [[ $yourSum -gt $dealerSum ]]; then
			echo -e "\nWow! you won! Good Job!"
			won
		else
			echo -e "\nUnexpected outcome! better fix something!"
		fi
	}
	busted () {
		if [[ $yourSum -gt 21 ]]; then
                                echo "Oh no! you busted!"
                                lost
                                playing=false
		fi
		sleep 2
	}	

	hitsum=0
	while $playing; do {
		clear
		printCards
		echo "User: $name"
		echo "Score: $score"
		echo "Bet: $bet" 
		echo -e "\nType h[it] to hit"
		echo "Type [dd] to double down"
		echo "Type s[tay] to stay"
		echo -e "Type e[xit] to return to the main menu!\n"
		read gameInput
	
		if [[ "$gameInput" =~ ^[eE](xit)? ]]; then {
			playing=false
		} elif [[ "$gameInput" =~ ^[sS](tay)? ]]; then {
			whoWon
			sleep 3
			playing=false		
		} elif [[ "$gameInput" =~ ^[hH](it)? ]]; then { 
			echo "You hit!"
			let hitsum++
			sleep 2
			yourCards+=(${cards[$RANDOM % 13]})
			printCards
			getyoursum
			sleep 1
			busted
		} elif [[ "$gameInput" =~ ^[dD]{1,2} ]]; then {
			if [ $hitsum -gt 0 ]; then {
				echo -e "\nYou've already hit!"
				sleep 3
			} else {
				local tempsum=$(( $bet * 2 ))
				if [ $tempsum -gt $score ]; then
					echo -e "\nYou don't have enough points!"
					sleep 3
				else
					let bet=$tempsum
					echo -e "\nDouble Down!"
					sleep 2
					yourCards+=(${cards[$RANDOM % 13]})
					printCards
					getyoursum
					sleep 2
					whoWon
					playing=false
					sleep 3
				fi	
			} fi
		} else { 
			echo "$gameInput is not a valid input, please try again"
			sleep 3	
		} fi	
	} done
}

optionsmenu () {
	inoptionsmenu=true
	while $inoptionsmenu; do
		clear
		echo -e "Username: $name\n"
		echo "To change username type n[ame]"
		echo "To see saves type s[aves]"
		echo "To delete save file type d[elete]"
		echo -e "To return to the main menu type e[xit]\n"
		read options
		if [[ $options =~ ^[nN](ame)? ]]; then
			read -p "Please enter a new username: " name
			echo -e "\nUsername changed to: $name"
			sleep 3
		elif [[ $options =~ ^[sS](aves)? ]]; then
			if test -f '.savefile'; then
				echo -e "Current saves: \n"
				cat '.savefile'
				echo -e "\nPress enter to continue..."
				read -s
			else
				echo "No save file found"
				sleep 3
			fi
		elif [[ $options =~ ^[dD](elete)? ]]; then
			echo -e "\nAre you sure? All saves will be lost! [y/N]"
			read delete
			if [[ $delete =~ [yY](es)? ]]; then
				if test -f '.savefile'; then
					rm .savefile
					echo "Save file deleted" 
					sleep 3
				else
					echo "No save file found"
					sleep 3
				fi
			else 
				echo "Delete aborted"
				sleep 3
			fi	
		elif [[ $options =~ ^[eE](xit)? ]]; then
			echo "Returning to main menu"
			sleep 3
			inoptionsmenu=false
		else
			echo "$options is an invalid option, please try again"
			sleep 3
		fi
	done
}

while $inMenu; do {
	clear
	echo "Username: $name"
	echo "Score: $score" 
	echo -e "\nType p[lay] to play Blackjack!"
	echo "Type s[ave] to save your game"
	echo "Type l[oad] to load a game"
	echo "Type o[ptions] for the options menu"
	echo -e "Type e[xit] to exit\n"
	read input
	if [[ "$input" =~ ^[Pp](lay)? ]]; then {
		if [ $score -le 0 ]; then
			echo "You don't have any money!"
			sleep 3
		else
			blackjack
		fi
	} elif [[ "$input" =~ ^[Ee](xit)? ]]; then {
		echo "Goodbye! "
		sleep 3
		inMenu=false
		exit
	} elif [[ "$input" =~ ^[oO0](ptions)? ]]; then {
		optionsmenu	
	} elif [[ "$input" =~ ^[sS](ave)? ]]; then { 
		if test -f '.savefile'; then
			echo "save file found"
			sleep 2
		else
			echo "save file not found, making new save file" 
			touch '.savefile'
			sleep 2
		fi
		nameExists=false
		for x in $(awk '{print $1}' .savefile); do
			if [ $name == $x ]; then
				nameExists=true
			fi
		done
		if $nameExists; then
			echo $name"-2" $score >> .savefile
			echo -e "\nUser $name found in save file, saved as $name-2"
			name="$name-2"
			sleep 3
		else
			echo $name $score >> .savefile
			echo -e  "\nUser $name saved"
			sleep 3
		fi
	} elif [[ "$input" =~ ^[lL](oad)? ]]; then { 
		if test -f '.savefile'; then
			echo -e "save file found\n"
			sleep 3
			cat '.savefile'
			sleep 3
			echo -e "\nPlease type the name of the player you'd like to load\n"
			read load
			found=false
			for n in $(awk '{print $1}' .savefile); do
				if [ $load == $n ]; then
					found=true
					echo -e "\nLoaded user $n"
					name=$n
					score=$(cat .savefile | grep $n | awk '{print $2}')
					sleep 3
				fi	
			done
			if ! $found; then 
				echo -e "\nNo user by the name of $load was found" 
				sleep 3
			fi
		else
			echo "no save file found :(" 
			sleep 3
		fi
	} else {
		echo "$input is not a valid input, please try again"
		sleep 3
	} fi
} done
