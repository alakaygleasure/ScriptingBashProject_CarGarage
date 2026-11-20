# Project plan
This is project is based on a high end luxury Motor Dealerships records and of recording and logging imports and export cars they purchase and sell they get in such as what cars, year, fuel type, milage, how many pervious owners, km/h, brand and a section at the end of the records of details of what garage and salesperson has the car been bought from or past through. 

## Project title
Luxury Car Garage 

## Intended user
User will be the employees of the Business

## Problem statement
Problem is trying to keep history of the which garages the cars have previously been with, sold out from and how many previous owners so the dealership can have a legal history of this, so this can resolve the issue of if the car is still considered newer and can be sold directly to a buyer or is the car not worth the garages resources time and money keeping and trying to sell. 


## Record structure
CarReg
CarBrand
Production_Year
NoOfOwners
CurrentMilage
PreviousGarageHistory
TimeInLot
FuelType
MarketRating
PriceEstimate

PreviousGarageHistory
## Unique identifier
Delimiter: Comma. 
Unique Record Identifier: CarReg.

## Planned menu

1. Display cars
2. Search by registration
3. Add an imported car
4. Show cars with a Low market rating
5. View recent imported records
6. Export a car from the active garage records
7. Update a car's market rating
8. Create a records copy and compressed project backup
9. Create the low-rating report
10. Exit

## Validation rules
CarReg is a primary key a unique identifier must not be left empty.
CarBrand cant be empty.
Production_Year Must be no older then 2027.  

## Planned reports
Filtering Cars in garage through MarketRating and TimeInLot to determine if how much of a discount should be applied.
How many garages and previous owners a car has had to determine the price for new cars coming in.
If a car has been in our TimeInLot for over a year then changes such as do we need to export it or just reduce the price more and even if we reduce the price by less than what we bought it for should we really export to another garage rather than making a loss. 
What cars have been exported and imported what is the history which will show all that have been. 

##At least two planned summaries. 
When updating a car the system must check that the CarReg exists. 
Cars that have been in the garage for more than six months may receive a discount of 5% off

##One planned exception report. 
Cant delete a car entry have to import to one another file of exports.View number of previous owners and record the garages the cars have been passed through this will help determine if the car should be discounted or exported for selling to another garage.

##Stage 1 startup approach and data filename
Main script is located in the sub directory folder project.sh in the main folder T00225081_Bash_Project
Records stored in records.txt