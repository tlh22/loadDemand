/***

Tidy incorrectly parked vehicles

***/


/*** CARs  ***/

UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 1,
    "NrCars" = "NrCars" - 1,
	"Notes" = '1 * Over bay markings'
WHERE TRIM("Notes") IN (
               '1 car parked wrong',
               '1 car over the bay line',
			   '1 car over pk line',
			   '1 car pk over the bay',
			   '1 car pk over the bay area',
			   'pk over bay line',
			   'poorly parked',
			   'parked badly',
			   'ONE OVERHANG',
			   'OVERHANG',
			   'parked over end',
			   'ONE BAD',
               'ONE CAR BAD' ,
			   'ONE BADLY' ,
			   'ONE BADLY.' ,
			   'ONE CAR BADLY' ,
			   'ONE CAR BADLY.' ,
			   '1 BAD' ,
			   '1 BADLY' ,
			   '1 BADLY.' ,
			   '1 CAR BAD' ,
			   'HALF IN BAY',
			   '1c poor',
			   '1c w poor',
			   '1c over end of bay'
			   '1c over',
			   '1 car pk over the bay line',
			   '1 car pk over bay line',
			   '1 CAR BADLY',
			   'pk over bay line',
			   'parked wrong',
			   '1c over end of bay',
			   '1c over'
			   );
			   
UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 2,
    "NrCars" = "NrCars" - 2,
	"Notes" = '2 * Over bay markings'
WHERE TRIM("Notes") IN (
               '2 cars parked wrong ',
			   'TWO BAD',
			   'TWO BADLY' ,
			   'TWO BADLY.' ,
			   '2 BAD' ,
			   '2 BADLY' ,
			   '2 BADLY.',
			   '2c poor',
			   '2 cars pk over the bay line',
			   '2 poor parked over lines',
			   '2 cars pk over bay line',
			   '2 cars parked wrong',
			   '2 CARS BADLY.',
			   '2w over line',
			   '2cars over lines',
			   '2 cars over the bay line'

			   );

UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 3,
    "NrCars" = "NrCars" - 3,
	"Notes" = '3 * Over bay markings'
WHERE TRIM("Notes") IN (
               '3 BAD',
			   '3 BADLY.',
			   '3 BADLY',
			   '3 cars pk over the bay line',
			   '3 cars pk over the bay area',
			   '3 cars parked wrong',
			   '3 cars over pk line',
			   '3 pk over bay line',
			   '3 cars pk over bay line'

			   );	
			   
UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 4,
    "NrCars" = "NrCars" - 4,
	"Notes" = '4 * Over bay markings'
WHERE TRIM("Notes") IN (
               '4 BAD',
			   '4 BADLY.',
			   '4 BADLY',
			   '4 cars pk over the bay line'

			   );	
		   			   
UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 5,
    "NrCars" = "NrCars" - 5,
	"Notes" = '5 * Over bay markings'
WHERE TRIM("Notes") IN (
               '5 BAD',
			   '5 BADLY.',
			   '5 BADLY', 
			   '5 cars pk over the bay line'

			   );			   
		   
UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 6,
    "NrCars" = "NrCars" - 6,
	"Notes" = '6 * Over bay markings'
WHERE TRIM("Notes") IN (
               '6 BAD',
			   '6 BAD.'

			   );	
			   
UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 7,
    "NrCars" = "NrCars" - 7,
	"Notes" = '7 * Over bay markings'
WHERE TRIM("Notes") IN (
               '7 BAD',
			   '7 BADLY'
			   '7 BADLY CARS'

			   );
			   
UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 9,
    "NrCars" = "NrCars" - 9,
	"Notes" = '9 * Over bay markings'
WHERE TRIM("Notes") IN (
               '9 BAD'

			   );

UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 910,
    "NrCars" = "NrCars" - 10,
	"Notes" = '9 * Over bay markings'
WHERE TRIM("Notes") IN (
               '9 BAD'

			   );
			   
-- Footway parking

UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 1,
    "NrCars" = "NrCars" - 1,
	"Notes" = '1 * 2W'
WHERE TRIM("Notes") IN (
              'HOHO',
              '2w',
			  '1 CAR HOHO',
			  '1 CAR 2W',
			  'ONE CAR HOHO',
			  'ONE 2W',
			  '1c 2w',
			  'ONE CAR 2W',
			  'ONE CAR 1W',
			  'ONE 1W',
			  'ONE CAR 2W',
			  'ONE 1W',
              'pk on footway',
              'one car hoho',
			  'half pk on the footwalk',
              'hoho pavement',
              '1 parked 2 wheels on kerb',
              '1 on pavement'			  

			   );

UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 2,
    "NrCars" = "NrCars" - 2,
	"Notes" = '2 * 2W'
WHERE TRIM("Notes") IN (
              '2c 2w',
              '2*2W',
			  '2 cars with wheels on footway'
			  '2CARS HOHO'
			  
			   );

UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 3,
    "NrCars" = "NrCars" - 3,
	"Notes" = '3 * 2W'
WHERE TRIM("Notes") IN (
              '3c 2w',
              '3*2W',
			  '3 cars with wheels on footway',
			  '3CARS HOHO'
			  
			   );				   			   

UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 4,
    "NrCars" = "NrCars" - 4,
	"Notes" = '4 * 2W'
WHERE TRIM("Notes") IN (
              '4c 2w',
              '4*2W',
			  '4 cars with wheels on footway',
			  '4CARS HOHO',
			  '4 WHEELS ON PAVEMENT'
			  
			   );		

UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 7,
    "NrCars" = "NrCars" - 7,
	"Notes" = '7 * 2W'
WHERE TRIM("Notes") IN (
              '7c 2w',
              '7*2W',
			  '7 cars with wheels on footway',
			  '7CARS HOHO'
			  
			   );				   

UPDATE demand."Counts" c
SET "NrCarsParkedIncorrectly" = 9,
    "NrCars" = "NrCars" - 9,
	"Notes" = '9 * 2W'
WHERE TRIM("Notes") IN (
              '9c 2w',
              '9*2W',
			  '9 cars with wheels on footway',
			  '9CARS HOHO'
			  
			   );				   
			   
-- LGVs			   

UPDATE demand."Counts" c
SET "NrLGVsParkedIncorrectly" = 1,
    "NrCars" = "NrLGVs" - 1,
	"Notes" = '1 * LGV Over bay markings'
WHERE TRIM("Notes") IN (
               '11 BAD',
               '1 car over the bay line',

			   );