#!/bin/bash
# SWDV61013 Bash Mini-Project
# Project title: Luxary Car Garage 
# Student name: Alex Gleasure
# Student number: T00225081
# Purpose: That employees the users of the system can access all records and of recording and logging imports and export cars they purchase and sell they get in such as what cars, year, fuel type, milage, how many pervious owners, km/h, brand and a section at the end of the records of details of what garage and salesperson has the car been bought from or past through and that they can edit the feilds.

# Stage 1: define variables and validate the project data file below.
PROJECT_TITLE="Luxary Car Garage" 
DATA_FILE="data/records.txt" 
REPORT_DIR="reports" 
BACKUP_DIR="backups" 

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
 
RECORD_COUNT=$(wc -l < "$DATA_FILE") #
 
echo "$PROJECT_TITLE" 
echo "Data file ready: $DATA_FILE" 
echo "Records available: $RECORD_COUNT" 
 
exit 0 