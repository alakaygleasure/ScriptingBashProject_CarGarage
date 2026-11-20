#!/bin/bash
# SWDV61013 Bash Mini-Project
# Project title: Luxary Car Garage 
# Student name: Alex Gleasure
# Student number: T00225081
# Purpose: That employees the users of the system can access all records and of recording and logging imports and export cars they purchase and sell they get in such as what cars, year, fuel type, milage, how many pervious owners, km/h, brand and a section at the end of the records of details of what garage and salesperson has the car been bought from or past through and that they can edit the feilds.

#Stage 1: define variables and validate the project data file below.
PROJECT_TITLE="Luxary Car Garage" 
DATA_FILE="data/records.txt" 
REPORT_DIR="reports" 
BACKUP_DIR="backups"
EMPLOYEE_ID="employee1"
EMPLOYEE_PASSWORD="1234"
#Extra features implemented during stage 3 this is a daily backup of record logs ,manual backup, activity log and low rating report 

#extra feature implemented during midterm before stage 3 after stage 2 was an employee login each employee has a login employee id number and a pin 
#Bash read reference was sourced from https://www.gnu.org/s/bash/manual/html_node/Bash-Builtins.html
employee_login() {     
    local entered_id entered_pin login_attempt
    login_attempt=0

    while [ "$login_attempt" -lt 3 ]; do   #-lt condition reference sourced from https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html

        read -r -p "Employee ID: " entered_id   #read -p idea was from https://www.gnu.org/s/bash/manual/html_node/Bash-Builtins.html
        read -r -s -p "Password: " entered_pin   
        echo

        if [ -z "$entered_id" ] || [ -z "$entered_pin" ]; then 
            echo "Error--- enter both an employee ID and Password!!!"
        elif [ "$entered_id" = "$EMPLOYEE_ID" ] && [ "$entered_pin" = "$EMPLOYEE_PASSWORD" ]; then #The test conditions was sourced from https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html
            employee_id="$entered_id"
            echo "Login successfull!!!!"
            echo "Welcome, employee $employee_id"
            employee_logs "Login" "All"
            return 0
        else
            echo "Staff ID or Password is incorrect"
        fi

        login_attempt=$((login_attempt + 1))
    done

    echo "Error -- Too many failed login attempts"
    return 1
}
#This writes the system actions into the activity log.
employee_logs() {
    local action="$1" 
    local car_reg="$2"     
    echo "$(date '+%Y-%m-%d %H:%M:%S'),$employee_id,$action,$car_reg" >> "$REPORT_DIR/activity_log.txt" #date was sourced from https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html
}
#Stage 4 Backups
daily_backups() {    #This saves one copy of the records file per day in the backups folder.
    local daily_backup 
    daily_backup="$BACKUP_DIR/records_$(date +%Y%m%d).txt" #date was sourced from https://man7.org/linux/man-pages/man1/date.1.html
    if [ ! -f "$daily_backup" ]; then #checks whether that date’s backup file does not already exist. If it exists, the function skips making another daily copy the file check reference was sourced from https://man.openbsd.org/OpenBSD-5.2/cp.1, https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html
        if cp "$DATA_FILE" "$daily_backup"; then  
            echo "Daily backup created: $daily_backup"
            employee_logs "DAILY_BACKUP" "ALL"
        else
            echo "Error: daily backup could not be created."
        fi
    fi
}
backup_records() {   #This makes an extra backup when the employee chooses the backup menu option.
    local timestamp backup_file archive_file
    timestamp=$(date +%Y%m%d_%H%M%S) #date format was sourced from https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html
    backup_file="$BACKUP_DIR/records_$timestamp.txt" #makes the backup file name
    archive_file="$BACKUP_DIR/project_backup_$timestamp.tar.gz"
    if cp "$DATA_FILE" "$backup_file"; then
        echo "Backup created: $backup_file"        #syntax and some of the code idea was sourced from https://www.geeksforgeeks.org/devops/daily-system-backup-script-with-versioning-auto-cleanup/
        if tar -czf "$archive_file" project.sh data documentation README.md; then
    if tar -tzf "$archive_file" > /dev/null; then
        echo "Compressed backup created and checked: $archive_file"
    else
        rm -f "$archive_file"
        echo "Error: compressed backup could not be checked."
        return 1
    fi
else
    echo "Error: compressed backup could not be created."
    return 1
fi
        employee_logs "BACKUP" "ALL"
    else
        echo "Error backup can not be created"
        
    fi
}
low_rating_report() {  #This saves the cars with a Low market rating in a report file.
    local report_file timestamp match total=$(wc -l < "$DATA_FILE")
    timestamp=$(date +%Y%m%d_%H%M%S) #date format was sourced from https was sourced from //www.gnu.org/software/coreutils/manual/html_node/date-invocation.html
    report_file="$REPORT_DIR/low_rating_$timestamp.txt"  
    match=$(grep -i ",Low," "$DATA_FILE")       #syntax and some of the code idea was sourced from https://www.geeksforgeeks.org/devops/daily-system-backup-script-with-versioning-auto-cleanup/
    {
        echo "Low Market rating report"
        echo "Created: $(date '+%Y-%m-%d %H:%M:%S')"  
        echo "Source: $DATA_FILE"
        echo "Total records: $total"
        echo
        echo "COUNT BY PRODUCTION YEAR"
        cut -d',' -f3 "$DATA_FILE" | sort | uniq -c
        echo

        echo "COUNT BY NUMBER OF OWNERS"
        cut -d',' -f4 "$DATA_FILE" | sort | uniq -c
        echo

        #Stage 4 Calculating the avergae milage reads the records using commas as separators. It skips mileage values marked N/A or 
          #left blank, adds up the other mileage values, and counts them. At the end, it divides the total mileage by the count to get the average
          #N/A was it i have in the records for empty data feilds. 5 for up to the 5th comma seperate feild which is current milage
        #sources used for this feature http://man.openbsd.org/awk, https://unix.stackexchange.com/questions/260621/to-calculate-average-by-taking-command-line-argument, https://www.gnu.org/software/gawk/manual/html_node/Fields.html , 
        echo "AVERAGE MILEAGE"  #
        awk -F',' '                          
        $5 != "N/A" && $5 != "" {   
            total = total + $5
            count = count + 1
        }
        END {10
            if (count == 0)
                print "No mileage values to average."
            else
                print "Average mileage:", total / count
        }' "$DATA_FILE"
        echo

        echo "LOW RATING EXCEPTIONS"
        if [ -n "$match" ]; then
            echo "$match"
        else
            echo "No cars have a Low market rating."
        fi
        echo
        echo "CARS SORTED BY BRAND"
        sort -t',' -k2,2 "$DATA_FILE"
    } > "$report_file"

    if [ -s "$report_file" ]; then
        echo "Report saved: $report_file"
        employee_logs "REPORT" "LOW_RATING"
        return 0
    else
        echo "Error: report could not be created."
        return 1
    fi
} 

if [ ! -f "$DATA_FILE" ]; then   
    echo "Error: required data file not found: $DATA_FILE"      
    exit 1 
fi 
 
if [ ! -r "$DATA_FILE" ]; then 
    echo "Error: data file is not readable: $DATA_FILE" 
    exit 1 
fi 
 
if [ ! -s "$DATA_FILE" ]; then 
    echo "Error: data file is empty: $DATA_FILE" 
    exit 1 
fi 
 
if employee_login; then
    daily_backups  #This creates today's backup after checking that the records file is ready.
else
    echo "Login failed. System closed."
    exit 1
fi

    RECORD_COUNT=$(wc -l < "$DATA_FILE") 
 
echo "$PROJECT_TITLE" 
echo "Data file ready: $DATA_FILE" 
echo "Records available: $RECORD_COUNT" 
 

#Stage 2: Display, Search and Add using menus, functions and if statements
display_records() {
    echo
    echo "CarReg | CarBrand | Production_Year | NoOfOwners | CurrentMilage | PreviousGarageHistory | TimeInLot | FuelType | MarketRating | PriceEstimate"
    echo "------------------------------------------------------------------------------------------------------------------------------------------"
    cat "$DATA_FILE"
    echo
}

search_record() {
    local search_id
    local matc
    read -r -p "Enter Car Reg: " search_id

    if [ -z "$search_id" ]; then
        echo "Error: Car Reg cannot be empty."
        return 1
    fi

    match=$(grep -i "^${search_id}," "$DATA_FILE")

    if [ -n "$match" ]; then
        echo "Matching car record:"
        echo "$match"
        return 0
    fi

    if [ -f "data/CarImportsRecords.txt" ]; then
        match=$(grep -i "^${search_id}," "data/CarImportsRecords.txt")

        if [ -n "$match" ]; then
            echo "Matching imported car record:"
            echo "$match"
            return 0
        fi
    fi

    echo "No car found with Car Reg: $search_id"
    return 1
}

add_record() {
    local car_reg car_brand production_year num_of_owners current_mileage
    local previous_garage_history time_in_lot fuel_type market_rating price_estimate

    read -r -p "Car Reg: " car_reg

    if [ -z "$car_reg" ]; then
        echo "Error: Car Reg cannot be empty."
        return 1
    fi

    if grep -qi "^${car_reg}," "$DATA_FILE"; then
        echo "Error: Car Reg already exists."
        return 1
    fi


#Over midterm after stage 2 before stage 3 added the code to import new cars records to import records file during midterm 
    if [ -f "data/CarImportsRecords.txt" ]; then
        if grep -qi "^${car_reg}," "data/CarImportsRecords.txt"; then
            echo "Car has been already added to Import Records" 
            return 1
        fi
    fi

    read -r -p "Car brand: " car_brand
    read -r -p "Production year: " production_year
    read -r -p "Number of owners: " num_of_owners
    read -r -p "Current mileage: " current_mileage
    read -r -p "Previous garage history: " previous_garage_history
    read -r -p "Time in lot: " time_in_lot
    read -r -p "Fuel type: " fuel_type
    read -r -p "Market rating (High, Medium or Low): " market_rating
    read -r -p "Price estimate: " price_estimate

    if [ -z "$car_brand" ] || [ -z "$production_year" ] ||
       [ -z "$num_of_owners" ] || [ -z "$current_mileage" ] ||
       [ -z "$previous_garage_history" ] || [ -z "$time_in_lot" ] ||
       [ -z "$fuel_type" ] || [ -z "$market_rating" ] ||
       [ -z "$price_estimate" ]; then    #Over midterm after stage 2 before stage 3 added the code to import new cars records to import records file during midterm 
               echo "Error all fields are required to complete car entry."
        return 1
    fi


#Additional scenario specific validation rules
case "$fuel_type" in
    Petrol|Diesel|Electric) ;;
    *) echo "Error: fuel type must be Petrol, Diesel or Electric."; 
return 1 ;;
esac

case "$market_rating" in   
     High|Medium|Low) ;;
        *)
            echo "Error: market rating must be not be empty, 3 only allowed entry's are High, Medium or Low."
            return 1
            ;;
    esac


#Validation Rule to make sure car year is entered is older than the current year, tried to do it with date instead of the current date the user is on the system which would get it from the pc like we have done previously with the $date command before the ca but I could only get it working with year 

current_year=$(date +%Y) #+%y gets the current year right now from the computer this sample of code was sourced from https://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/ **only the +%y command nothing else 

if [ "$production_year" -gt "$current_year" ]; then  #-gt means greater than so if the year the car was made is greater than the current year the employee is on the system then it wont work and the employee will receive an error message -gt operator was sourced from https://www.w3schools.com/bash/bash_operators.php

    echo "Error: production year can not be older than this year."
    return 1
fi

  echo "$car_reg,$car_brand,$production_year,$num_of_owners,$current_mileage,$previous_garage_history,$time_in_lot,$fuel_type,$market_rating,$price_estimate" >> "$DATA_FILE"
  echo "$car_reg,$car_brand,$production_year,$num_of_owners,$current_mileage,$previous_garage_history,$time_in_lot,$fuel_type,$market_rating,$price_estimate" >> "data/CarImportsRecords.txt"
    echo "Car record successfully added!!"
    employee_logs "IMPORT" "$car_reg"
    return 0
}

#Extra menu option I added same structure as search_layout option but didnt need the input and read options, I created a function called cars_that_may_need_update so we can view if cars have a market rating as low then they may need a big discount or may need to be exported out of the garage which will thne need to add that cars record to the exported files, I wnat to add more deciders on to this like has time_in_lot and number of previous owners **but didnt have time will look at this over midterm along with adding much more menu options following my project plan 

cars_that_may_need_update () {
    local match

    match=$(grep -i ",Low," "$DATA_FILE")

    if [ -n "$match" ]; then
        echo "The following are Cars with a Market Rating of Low that need may need a discount or be considered for export to anouther Garage:"
        echo "$match"
        return 0
    else
        echo "No cars in the Garage have a Low Market Rating, Nice"
        return 1
    fi
}
carImport_Record() {    #Over midterm after stage 2 before stage 3 I added the view import records function adding the cars entered in the add new car option
    echo
    echo "Imported car records"

    if [ -s "data/CarImportsRecords.txt" ]; then
        cat "data/CarImportsRecords.txt"
    else
        echo "They are no new Cars that have been Imported to us recently"
    fi
}
carExport_Record() { #Stage 3 Deletion used Export option added during midterm and combined the code from overmidterm with the delete code from session 15 where car is found due to reg and car from records.txt is mov to exported.txt
    local car_reg match line current_id confirm record_count
    local temp_file="${DATA_FILE}.tmp"
    local found=0
    read -r -p "Enter the Car Reg to export: " car_reg
    if [ -z "$car_reg" ]; then
        echo "Error: Car Reg must not be empty."
        return 1
    fi
    match=$(grep "^${car_reg}," "$DATA_FILE") 
    if [ -z "$match" ]; then
        echo "Car Reg not found in Car Records."
        return 1
    fi
    echo "Car selected: $match"
    read -r -p "Do you want to export this car? (yes/no): " confirm
    case "$confirm" in
        yes|YES|Yes) ;;
        *)
            echo "Export cancelled."
            return 0
            ;;
    esac
    record_count=$(wc -l < "$DATA_FILE")
    if [ "$record_count" -le 1 ]; then
        echo "Cannot export the last car because the records file must not be empty."
        return 1
    fi
    > "$temp_file"
    while IFS= read -r line; do
        current_id=${line%%,*} #Bash removes matching text from the end https://www.gnu.org/s/bash/manual/html_node/Shell-Parameter-Expansion.html
        if [ "$current_id" = "$car_reg" ]; then
            found=1
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$DATA_FILE"
    if [ "$found" -eq 1 ] && [ -s "$temp_file" ]; then
        if echo "$match" >> "data/Exports.txt"; then 
            if mv "$temp_file" "$DATA_FILE"; then 
                employee_logs "EXPORT" "$car_reg"
                echo "Car exported and removed from the garage records."
                echo "Exported record:"
                echo "$match"
            else
                rm -f "$temp_file" 
                echo "Error: export failed; original records were kept."
                return 1
            fi
        else
            rm -f "$temp_file"
            echo "Error: could not save the car to the export file."
            return 1
        fi
    else
        rm -f "$temp_file" 
        echo "Error: export failed; original records were kept."
        return 1
    fi
}
#stage 3 Updating
update_record() {
    local target_id current new_market_rating line current_id confirm
    local remaining car_details time_in_lot fuel_type price_estimate
    local temp_file="${DATA_FILE}.tmp"
    local found=0

    read -r -p "Car Reg to update: " target_id

    if [ -z "$target_id" ]; then
        echo "Error: Car Reg cannot be empty."
        return 1
    fi

    current=$(grep "^${target_id}," "$DATA_FILE")

    if [ -z "$current" ]; then

        echo "Error: Car Reg not found."
        return 1
    fi

    echo "Current record: $current"
   while true; do
    read -r -p "New market rating (High, Medium or Low): " new_market_rating

    case "$new_market_rating" in
        High|Medium|Low)
            break
            ;;
        *)
            echo "Error: enter High, Medium or Low."
            ;;
    esac

done

read -r -p "Confirm this update? (yes/no): " confirm

case "$confirm" in
    yes|YES|Yes) ;;
    *)
        echo "Update cancelled."
        return 0
        ;;
esac

    > "$temp_file" 

    while IFS= read -r line; do #read was sourced from https://www.gnu.org/s/bash/manual/html_node/Bash-Builtins.html
        current_id=${line%%,*} 

        if [ "$current_id" = "$target_id" ]; then
            IFS=',' read -r car_reg car_brand production_year num_of_owners current_mileage previous_garage_history time_in_lot fuel_type market_rating price_estimate <<< "$line" # read and IFS reference: https://www.gnu.org/s/bash/manual/html_node/Bash-Builtins.html

            echo "$car_reg,$car_brand,$production_year,$num_of_owners,$current_mileage,$previous_garage_history,$time_in_lot,$fuel_type,$new_market_rating,$price_estimate" >> "$temp_file" # append reference: https://www.gnu.org/s/bash/manual/html_node/Redirections.html
            found=1
        else
            echo "$line" >> "$temp_file" 
        fi
    done < "$DATA_FILE"


    if [ "$found" -eq 1 ]; then
    if mv "$temp_file" "$DATA_FILE"; then 
    employee_logs "UPDATE_RATING" "$target_id"
    echo "Record updated successfully!!!!"
    echo "Updated record:"
    grep "^${target_id}," "$DATA_FILE"
    else
    rm -f "$temp_file"
    echo "Error: update failed; original file preserved."
    return 1

    fi


    else
        rm -f "$temp_file" 
        echo "Error: update failed; original file preserved."
        return 1
    fi
}

   show_menu() {  #Over MidTerm I touched up the user interface these color codes and style options where sourced from https://web.archive.org/web/20260824134929/https://misc.flogisoft.com/bash/tip_colors_and_formatting
      echo
    echo -e "\e[1;96m+------------------------------------------------+\e[0m"
    echo -e "\e[1;97;44m             $PROJECT_TITLE              \e[0m"
    echo -e "\e[1;96m+------------------------------------------------+\e[0m"
    echo
    echo -e "\e[1;4;93m                 MAIN MENU\e[0m"
    echo
    echo -e "\e[1;92m[1]\e[0m Display all the Cars"
    echo -e "\e[1;92m[2]\e[0m Search by the Car Reg"
    echo -e "\e[1;92m[3]\e[0m Add a new imported car"
    echo -e "\e[1;92m[4]\e[0m Cars that may need an Update on price or be considered for export"
    echo -e "\e[1;92m[5]\e[0m Records of New Recent Imported Cars"
    echo -e "\e[1;92m[6]\e[0m Export Car out of the Garage"
    echo -e "\e[1;92m[7]\e[0m Update a car's market rating"
    echo -e "\e[1;92m[8]\e[0m Create a records backup"
    echo -e "\e[1;92m[9]\e[0m Create a low ratings report"
    echo -e "\e[1;91m[10] Exit\e[0m"
    echo
    echo -e "\e[1;96m+------------------------------------------------+\e[0m"
}

invalid_attempt=0
while true; do

#This one if the user is spending too much time on the system it pops up a message do they need any help, this is what I have for it now but I am trying to do it where instead its based on is there two many errors being outputted on the terminal like if amount of errors is -ge 4 or another idea is if there is no activity or motion like has system been running but no activity it may pop up this message or automatically log out for security reasons I wasn't able to get it working before Friday but will keep working on this during midterm especially to intergrade in an another week 
#if [ "$SECONDS" -gt 500 ]; then  #Seconds built in variable was sourced from website https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html only seconds is used for this I couldn't find any built in hours one I don't believe there is one 

    #echo "You have been using the system for a very long time do you need help??"

    show_menu
    read -r -p "Choose one of the menu options: " choice

    case "$choice" in
        1) display_records ;;
        2) search_record ;;
        3) add_record ;;
        4) cars_that_may_need_update ;;
        5) carImport_Record ;;
        6) carExport_Record ;;
        7) update_record ;;  #Stage 3 Update Changes
        8) backup_records ;;  
        9) low_rating_report ;;
        10) echo "Thank You GoodBye"; break ;;
        *)
            echo "Invalid option. Choose an option between 1 and 10."   #Over midterm after stage 2 before stage 3 following on from my attempt at it in week 2 where if the user enters incorrect commands a number of times a do you need help message shows up
            invalid_attempt=$((invalid_attempt + 1))  #code for it was sourced from the code syntax i=$((i+1)) from this website https://linuxize.com/post/bash-increment-decrement-variable/ the incrementing counting is the same has we have done in Java script recently so this expression does the same 

            if [ "$invalid_attempt" -ge 4 ]; then
                echo "You have keep entering an invalid option do you need any help????"
               invalid_attempt=0
            fi
            ;;
    esac

    if [ "$choice" != "10" ]; then
        read -r -p "Press Enter to return to the menu: " pause
    fi
done

#Cron Job Referenced from https://www.gnu.org/software/coreutils/manual/html_node/Formatting-file-timestamps.html, https://man7.org/linux/man-pages/man5/crontab.5.html, https://www.gnu.org/software/coreutils/manual/html_node/Basic-operations.html