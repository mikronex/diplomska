 	LIST p=16f84a

	INCLUDE "p16f84a.inc"
	__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC

	cblock 0x0c		;deklarisanje promenljivih

	trHOR,multiR1,multiR2,crneLIN,brojPRE,trEQU,brojVER,trVER,brojPOST
	TAJMER,POLJE,CARRY
	WHITE,YELLOW,CYAN,GREEN,MAGEN,RED,BLUE,BLACK,brLIN

	Endc			;zavrsetak deklarisanja

Bela         EQU B'00011101'
Zuta         EQU B'00011001'
Tirkiz       EQU B'00010101'
Zelena       EQU B'00010001'
Ljubicasta   EQU B'00001101'
Crvena       EQU B'00001001'
Plava        EQU B'00000101'
Crna         EQU B'00000001'

	org 0h			;reset vektor

	CLRF PORTA 		;svi bitovi na 0
	CLRF PORTB 		;svi bitovi na 0
	BSF STATUS,RP0 		;ulaz u bank 1
	MOVLW B'11111111'
	MOVWF TRISA 		;PORTA input
	CLRF TRISB		;PORTB output
	BCF STATUS,RP0 		;povratak u bank 0

	MOVLW 0
	MOVWF CARRY		;sluzi za kontrolu CARRY
	BCF STATUS,C		;resetovanje C fleg-a (bit 0 u STATUS registru)
	MOVLW B'10101010'
	MOVWF POLJE		;kontrola polja
P1P2
	BTFSS PORTA,3
	GOTO DALJE
	BTFSC PORTA,2
	GOTO REDOVI
	GOTO RESETKE
DALJE
	BTFSC PORTA,2
	GOTO TACKE

;***** KOLONE U BOJI *****

KOLONE
	RRF POLJE,1
	MOVLW D'3'		;linije bez videa posle post-equalizing pulseva
	BTFSS POLJE,0		;ako je polje 1, imacemo 3 crne linije
	MOVLW D'4'		;u polju 2 cemo imati 4 crne linije
	MOVWF crneLIN
	MOVLW D'99'
	MOVWF multiR1		;broj linija u jednom bloku
	MOVLW D'3'
	MOVWF multiR2		;broj blokova
	MOVLW 5
	MOVWF brojPRE		;broj pre-equalizing pulseva
	MOVLW 5
	MOVWF brojVER		;broj vertikalnih sinhronizacionih pulseva
	MOVLW 5
	MOVWF brojPOST		;broj post-equalizing pulseva
PREEQU				;PRE-EQUALIZING pulsevi
	BCF PORTB,0		;sinhronizam 2,4µs low
	MOVLW D'23'
	MOVWF trEQU
	NOP
	NOP
	NOP
	BSF PORTB,0
LOOP1
	DECFSZ trEQU,1		;sinhronizam 29,6µs high, zajedno daju 32µs
	GOTO LOOP1
	NOP
	NOP
	DECFSZ brojPRE,1
	GOTO PREEQU
	NOP
VERT				;VERTIKALNI sinhronizam
	BCF PORTB,0		;sinhronizam 27,2µs low
	MOVLW D'22'
	MOVWF trVER
LOOP2
	DECFSZ trVER,1
	GOTO LOOP2
	BSF PORTB,0		;sinhronizam 4,8µs high, zajedno daju 32µs
	MOVLW 2
	MOVWF TAJMER
TIME
	DECFSZ TAJMER,1
	GOTO TIME
	NOP
	DECFSZ brojVER,1
	GOTO VERT
	NOP
POSEQU				;POST-EQUALIZING pulsevi
	BCF PORTB,0		;sinhronizam 2,4µs low
	MOVLW D'23'
	MOVWF trEQU
	NOP
	NOP
	NOP
	BSF PORTB,0
LOOP3
	DECFSZ trEQU,1		;sinhronizam 29,6µs high, zajedno daju 32µs
	GOTO LOOP3
	NOP
	NOP
	DECFSZ brojPOST,1
	GOTO POSEQU
	NOP
;Pocinjemo sa ispisom linija
;U prvom polju, pocinjemo sa celom linijom, dok drugo polje
;pocinje sa pola linije koja ne sadrzi horizontalni sinhronizam
	RLF PORTB,1		;1 ili ½ linije zapocinje polje
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVLW D'21'		;vreme za ½ linije
	BTFSS PORTB,0		;ako je polje 1, dodaje se jos vremena
	ADDLW D'27'		;vreme za celu liniju
	MOVWF trHOR		;odredjuje trajanje linije
	BSF PORTB,0
	BTFSS POLJE,0
	GOTO NEXT
NEXT
	BCF PORTB,1
	NOP
LOOP
	DECFSZ trHOR,1
	GOTO LOOP
	NOP
;3 ili 4 linije su nacinjene da bi se doslo do 625 linija u normi B/G
;ako je polje 1, imacemo 3 linije, jer smo jednu vec napravili
HORIZ
	BCF PORTB,0		;horizontalni sinhronizam: 4,8µs
	MOVLW 2
	MOVWF TAJMER
TIME3
	DECFSZ TAJMER,1
	GOTO TIME3
	NOP
	NOP
	MOVLW D'48'
	MOVWF trHOR
	BSF PORTB,0
LOOPH3
	DECFSZ trHOR,1
	GOTO LOOPH3
	NOP
	DECFSZ crneLIN,1
	GOTO HORIZ
	NOP
;3 bloka od 99 linija + 1 linija posle svakog bloka
;3*(99+1)=300 linija
HORIZ1
	BCF PORTB,0		;horizontalni sinhronizam, prva linija u boji
	MOVLW 2
	MOVWF TAJMER
TIME1
	DECFSZ TAJMER,1
	GOTO TIME1
	NOP
	NOP
	NOP
	NOP
	BSF PORTB,0
	NOP
	NOP
	NOP
	MOVLW 5
	MOVWF WHITE		;trajanje Bele (6,4µs)
	MOVWF YELLOW		;trajanje Zute
	MOVWF CYAN		;trajanje Tirkizne
	MOVWF GREEN		;trajanje Zelene
	MOVWF MAGEN		;trajanje Ljubicaste
	MOVWF RED		;trajanje Crvene
	MOVWF BLUE		;trajanje Plave
	MOVWF BLACK		;trajanje Crne
	MOVLW Bela
	MOVWF PORTB
WHITE1
	DECFSZ WHITE,1
	GOTO WHITE1
	MOVLW Zuta
	MOVWF PORTB
YELLO1
	DECFSZ YELLOW,1
	GOTO YELLO1
	MOVLW Tirkiz
	MOVWF PORTB
CYAN1
	DECFSZ CYAN,1
	GOTO CYAN1
	MOVLW Zelena
	MOVWF PORTB
GREEN1
	DECFSZ GREEN,1
	GOTO GREEN1
	MOVLW Ljubicasta
	MOVWF PORTB
MAGEN1
	DECFSZ MAGEN,1
	GOTO MAGEN1
	MOVLW Crvena
	MOVWF PORTB
RED1
	DECFSZ RED,1
	GOTO RED1
	MOVLW Plava
	MOVWF PORTB
BLUE1
	DECFSZ BLUE,1
	GOTO BLUE1
	MOVLW Crna
	MOVWF PORTB
BLACK1
	DECFSZ BLACK,1
	GOTO BLACK1
	NOP
	NOP
	NOP
	NOP
	DECFSZ multiR1,1
	GOTO HORIZ1
	NOP
HORIZ2
	BCF PORTB,0
	MOVLW 2
	MOVWF TAJMER
TIME2
	DECFSZ TAJMER,1
	GOTO TIME2
	MOVLW D'99'
	MOVWF multiR1
	NOP
	NOP
	BSF PORTB,0
	NOP
	NOP
	NOP
	MOVLW 5
	MOVWF WHITE
	MOVWF YELLOW
	MOVWF CYAN
	MOVWF GREEN
	MOVWF MAGEN
	MOVWF RED
	MOVWF BLUE
	MOVWF BLACK
	MOVLW Bela
	MOVWF PORTB
WHITE2
	DECFSZ WHITE,1
	GOTO WHITE2
	MOVLW Zuta
	MOVWF PORTB
YELLO2
	DECFSZ YELLOW,1
	GOTO YELLO2
	MOVLW Tirkiz
	MOVWF PORTB
CYAN2
	DECFSZ CYAN,1
	GOTO CYAN2
	MOVLW Zelena
	MOVWF PORTB
GREEN2
	DECFSZ GREEN,1
	GOTO GREEN2
	MOVLW Ljubicasta
	MOVWF PORTB
MAGEN2
	DECFSZ MAGEN,1
	GOTO MAGEN2
	MOVLW Crvena
	MOVWF PORTB
RED2
	DECFSZ RED,1
	GOTO RED2
	MOVLW Plava
	MOVWF PORTB
BLUE2
	DECFSZ BLUE,1
	GOTO BLUE2
	MOVLW Crna
	MOVWF PORTB
BLACK2
	DECFSZ BLACK,1
	GOTO BLACK2
	NOP
	NOP
	NOP
	NOP
	DECFSZ multiR2,1
	GOTO HORIZ1
	NOP
;Polje je kompletirano. Sledeca linija se koristi
;za ucitavanje promenljivih...
	BCF PORTB,0
	NOP
	NOP
	MOVLW 0
	BTFSC POLJE,0
	MOVLW 1
	MOVWF CARRY
	NOP
	MOVLW D'15'		;za pola linije (polje 2)
	BTFSC POLJE,0
	ADDLW D'24'		;za celu liniju (polje 1)
	MOVWF trHOR
	BSF PORTB,0
	BTFSS POLJE,0
	GOTO NEXT1
NEXT1
	NOP
	NOP
LOOPH5
	DECFSZ trHOR,1
	GOTO LOOPH5
	RRF CARRY,1
	BTFSC PORTA,2
	GOTO P1P2
	BTFSC PORTA,3
	GOTO P1P2
	NOP
	NOP
	NOP
	NOP
	NOP
	GOTO KOLONE		;nije doslo do promene obrasca

;***** TACKE *****

TACKE
	RRF POLJE,1
	NOP
	NOP
	MOVLW D'4'
	MOVWF crneLIN		;svako polje pocinje sa 4 crne linije
	MOVLW D'28'
	MOVWF multiR1		;broj linija izmedju tacaka po vertikali
	MOVLW D'10'
	MOVWF multiR2		;broj blokova. 30 linija u jednom bloku (28+2)
	MOVLW 4
	MOVWF brojPRE		;broj pre-equalizing pulseva
	MOVLW 5
	MOVWF brojVER		;broj vertikalnih sinhronizacionih pulseva
	MOVLW 5
	MOVWF brojPOST		;broj post-equalizing pulseva
DPREEQU				;PRE-EQUALIZING pulsevi
	BCF PORTB,0
	MOVLW D'23'
	MOVWF trEQU
	NOP
	NOP
	NOP
	BSF PORTB,0
DLOOP1
	DECFSZ trEQU,1
	GOTO DLOOP1
	NOP
	NOP
	DECFSZ brojPRE,1
	GOTO DPREEQU
	NOP
DVERT				;VERTIKALNI sinhronizam
	BCF PORTB,0
	MOVLW D'22'
	MOVWF trVER
DLOOP2
	DECFSZ trVER,1
	GOTO DLOOP2
	BSF PORTB,0
	MOVLW 2
	MOVWF TAJMER
DTIME
	DECFSZ TAJMER,1
	GOTO DTIME
	NOP
	DECFSZ brojVER,1
	GOTO DVERT
	NOP
DPOSEQU				;POST-EQUALIZING pulsevi
	BCF PORTB,0
	MOVLW D'23'
	MOVWF trEQU
	NOP
	NOP
	NOP
	BSF PORTB,0
DLOOP3
	DECFSZ trEQU,1
	GOTO DLOOP3
	NOP
	NOP
	DECFSZ brojPOST,1
	GOTO DPOSEQU
	NOP
	NOP			;"5"-a linija koja pocinje sa 2,4µs low Sync.
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVLW D'21'
	MOVWF trHOR		;trajanje "5"-e linije
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,1
	NOP
DLOOP
	DECFSZ trHOR,1
	GOTO DLOOP
	NOP
DHORIZ				;4 crne linije pre linija u boji
	BCF PORTB,0
	MOVLW 2
	MOVWF TAJMER
DTIME3
	DECFSZ TAJMER,1
	GOTO DTIME3
	NOP
	NOP
	MOVLW D'48'
	MOVWF trHOR
	BSF PORTB,0
DLOOPH3
	DECFSZ trHOR,1
	GOTO DLOOPH3
	NOP
	DECFSZ crneLIN,1
	GOTO DHORIZ
	NOP
DHORIZ1				;pocetak ispisa u "boji"
	BCF PORTB,0
	MOVLW 2
	MOVWF TAJMER
DTIME1
	DECFSZ TAJMER,1
	GOTO DTIME1
	NOP
	NOP
	MOVLW D'48'
	MOVWF trHOR
	BSF PORTB,0
DLOOPHZ
	DECFSZ trHOR,1
	GOTO DLOOPHZ
	NOP
	DECFSZ multiR1,1
	GOTO DHORIZ1
	NOP
	BCF PORTB,0
	MOVLW 2
	MOVWF TAJMER
DTIMEZ
	DECFSZ TAJMER,1
	GOTO DTIMEZ
	NOP
	NOP
	MOVLW 9
	MOVWF brLIN
	BSF PORTB,0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
DLOOPHA
	MOVLW B'00011100'
	ADDWF PORTB,1
	SUBWF PORTB,1
	NOP
	MOVLW 2
	MOVWF trHOR
DLOOPH4
	DECFSZ trHOR,1
	GOTO DLOOPH4
	DECFSZ brLIN,1
	GOTO DLOOPHA
	NOP
	MOVLW B'00011100'
	ADDWF PORTB,1		;deseta tacka
	SUBWF PORTB,1
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,0
	MOVLW 2
	MOVWF TAJMER
DTIME2
	DECFSZ TAJMER,1
	GOTO DTIME2
	MOVLW D'28'
	MOVWF multiR1
	MOVLW 9
	MOVWF brLIN
	BSF PORTB,0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
DLOOPHB
	MOVLW B'00011100'
	ADDWF PORTB,1
	SUBWF PORTB,1
	NOP
	MOVLW 2
	MOVWF trHOR
DLOOPH5
	DECFSZ trHOR,1
	GOTO DLOOPH5
	DECFSZ brLIN,1
	GOTO DLOOPHB
	NOP
	MOVLW B'00011100'
	ADDWF PORTB,1		;deseta tacka, kompletirana
	SUBWF PORTB,1
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ multiR2,1	
	GOTO DHORIZ1
	NOP
;Polje je kompletirano, sledi pola linije...
	BCF PORTB,0
	NOP
	NOP
	MOVLW 0
	BTFSC POLJE,0
	MOVLW 1
	MOVWF CARRY
	NOP
	NOP
	NOP
	MOVLW D'15'
	MOVWF trHOR
	BSF PORTB,0
	NOP
	NOP
	NOP
	NOP
	NOP
DLOOPH6
	DECFSZ trHOR,1
	GOTO DLOOPH6
	RRF CARRY,1
	BTFSS PORTA,2
	GOTO P1P2
	BTFSC PORTA,3
	GOTO P1P2
	NOP
	NOP
	NOP
	NOP
	NOP
	GOTO TACKE		;nije doslo do promene obrasca

;***** RESETKE *****

RESETKE
	RRF POLJE,1
	NOP
	NOP
	MOVLW D'4'
	MOVWF crneLIN		;svako polje pocinje sa 4 crne linije
	MOVLW D'28'
	MOVWF multiR1		;broj vert. linija koje cine "||||||||||"
	MOVLW D'10'
	MOVWF multiR2		;broj blokova. 30 linija u jednom bloku (28+2)
	MOVLW 4
	MOVWF brojPRE		;broj pre-equalizing pulseva
	MOVLW 5
	MOVWF brojVER		;broj vertikalnih sinhronizacionih pulseva
	MOVLW 5
	MOVWF brojPOST		;broj post-equalizing pulseva
BPREEQU				;PRE-EQUALIZING pulsevi
	BCF PORTB,0
	MOVLW D'23'
	MOVWF trEQU
	NOP
	NOP
	NOP
	BSF PORTB,0
BLOOP1
	DECFSZ trEQU,1
	GOTO BLOOP1
	NOP
	NOP
	DECFSZ brojPRE,1
	GOTO BPREEQU
	NOP
BVERT				;VERTIKALNI sinhronizam
	BCF PORTB,0
	MOVLW D'22'
	MOVWF trVER
BLOOP2
	DECFSZ trVER,1
	GOTO BLOOP2
	BSF PORTB,0
	MOVLW 2
	MOVWF TAJMER
BTIME
	DECFSZ TAJMER,1
	GOTO BTIME
	NOP
	DECFSZ brojVER,1
	GOTO BVERT
	NOP
BPOSEQU				;POST-EQUALIZING pulsevi
	BCF PORTB,0
	MOVLW D'23'
	MOVWF trEQU
	NOP
	NOP
	NOP
	BSF PORTB,0
BLOOP3
	DECFSZ trEQU,1
	GOTO BLOOP3
	NOP
	NOP
	DECFSZ brojPOST,1
	GOTO BPOSEQU
	NOP
	NOP			;"5"-a linija koja pocinje sa 2,4µs low Sync.
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVLW D'21'
	MOVWF trHOR		;trajanje "5"-e linije
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,1
	NOP
BLOOP
	DECFSZ trHOR,1
	GOTO BLOOP
	NOP
BHORIZ				;4 crne linije pre linija u boji
	BCF PORTB,0
	MOVLW 2
	MOVWF TAJMER
BTIME3
	DECFSZ TAJMER,1
	GOTO BTIME3
	NOP
	NOP
	MOVLW D'48'
	MOVWF trHOR
	BSF PORTB,0
BLOOPH3
	DECFSZ trHOR,1
	GOTO BLOOPH3
	NOP
	DECFSZ crneLIN,1
	GOTO BHORIZ
	NOP
BHORIZ1				;pocetak ispisa u "boji"
	BCF PORTB,0
	MOVLW 2
	MOVWF TAJMER
BTIME1
	DECFSZ TAJMER,1
	GOTO BTIME1
	NOP
	NOP
	MOVLW 9
	MOVWF brLIN
	BSF PORTB,0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
BLOOPHA
	MOVLW B'00011100'
	ADDWF PORTB,1
	SUBWF PORTB,1
	NOP
	MOVLW 2
	MOVWF trHOR
BLOOPH4
	DECFSZ trHOR,1
	GOTO BLOOPH4
	DECFSZ brLIN,1
	GOTO BLOOPHA
	NOP
	MOVLW B'00011100'
	ADDWF PORTB,1
	SUBWF PORTB,1
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ multiR1,1
	GOTO BHORIZ1
	NOP
	BCF PORTB,0
	MOVLW 2
	MOVWF TAJMER
BTIMEZ
	DECFSZ TAJMER,1
	GOTO BTIMEZ
	NOP
	NOP
	MOVLW D'44'
	MOVWF trHOR		;trajanje linije
	BSF PORTB,0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVLW B'00011101'
	MOVWF PORTB
BLOOPHZ
	DECFSZ trHOR,1
	GOTO BLOOPHZ
	MOVLW B'00000001'
	MOVWF PORTB		;gasimo liniju
	NOP
	NOP
	NOP
	BCF PORTB,0
	MOVLW 2
	MOVWF TAJMER
BTIME2
	DECFSZ TAJMER,1
	GOTO BTIME2
	MOVLW D'28'
	MOVWF multiR1
	MOVLW D'44'
	MOVWF trHOR
	BSF PORTB,0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVLW B'00011101'
	MOVWF PORTB
BLOOPH5
	DECFSZ trHOR,1
	GOTO BLOOPH5
	MOVLW B'00000001'
	MOVWF PORTB		;formirana je i druga linija
	DECFSZ multiR2,1
	GOTO BHORIZ1
	NOP
;Polje je kompletirano, sledi pola linije... 
	BCF PORTB,0
	NOP
	NOP
	MOVLW 0
	BTFSC POLJE,0
	MOVLW 1
	MOVWF CARRY
	NOP
	NOP
	NOP
	MOVLW D'15'
	MOVWF trHOR
	BSF PORTB,0
	NOP
	NOP
	NOP
	NOP
	NOP
BLOOPH6
	DECFSZ trHOR,1
	GOTO BLOOPH6
	RRF CARRY,1
	BTFSC PORTA,2
	GOTO P1P2
	BTFSS PORTA,3
	GOTO P1P2
	NOP
	NOP
	NOP
	NOP
	NOP
	GOTO RESETKE		;nije doslo do promene obrasca

;***** REDOVI U BOJI *****

REDOVI
	RRF POLJE,1
	MOVLW D'3'		;linije bez videa posle post-equalizing pulseva
	BTFSS POLJE,0		;ako je polje 1, imacemo 3 crne linije
	MOVLW D'4'		;u polju 2 cemo imati 4 crne linije
	MOVWF crneLIN
	NOP
	CLRF multiR1		;broj linija u JEDNOJ boji
	MOVLW D'29'
	MOVWF multiR2		;boja (29=bela)
	MOVLW 5
	MOVWF brojPRE		;broj pre-equalizing pulseva
	MOVLW 5
	MOVWF brojVER		;broj vertikalnih sinhronizacionih pulseva
	MOVLW 5
	MOVWF brojPOST		;broj post-equalizing pulseva
CPREEQU				;PRE-EQUALIZING pulsevi
	BCF PORTB,0
	MOVLW D'23'
	MOVWF trEQU
	NOP
	NOP
	NOP
	BSF PORTB,0
CLOOP1
	DECFSZ trEQU,1
	GOTO CLOOP1
	NOP
	NOP
	DECFSZ brojPRE,1
	GOTO CPREEQU
	NOP
CVERT				;VERTIKALNI sinhronizam
	BCF PORTB,0
	MOVLW D'22'
	MOVWF trVER
CLOOP2
	DECFSZ trVER,1
	GOTO CLOOP2
	BSF PORTB,0
	MOVLW 2
	MOVWF TAJMER
CTIME
	DECFSZ TAJMER,1
	GOTO CTIME
	NOP
	DECFSZ brojVER,1
	GOTO CVERT
	NOP
CPOSEQU				;POST-EQUALIZING pulsevi
	BCF PORTB,0
	MOVLW D'23'
	MOVWF trEQU
	NOP
	NOP
	NOP
	BSF PORTB,0
CLOOP3
	DECFSZ trEQU,1
	GOTO CLOOP3
	NOP
	NOP
	DECFSZ brojPOST,1
	GOTO CPOSEQU
	NOP
;Pocinjemo sa ispisom linija
;U prvom polju, pocinjemo sa celom linijom, dok drugo polje
;pocinje sa pola linije koja ne sadrzi horizontalni sinhronizam
	RLF PORTB,1		;1 ili ½ linije zapocinje polje
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVLW D'21'		;vreme za ½ linije
	BTFSS PORTB,0		;ako je polje 1, dodaje se jos vremena
	ADDLW D'27'		;vreme za celu liniju
	MOVWF trHOR		;odredjuje trajanje linije
	BSF PORTB,0
	BTFSS POLJE,0
	GOTO CNEXT
CNEXT
	BCF PORTB,1
	NOP
CLOOP
	DECFSZ trHOR,1
	GOTO CLOOP
	NOP
;3 ili 4 linije su nacinjene da bi se doslo do 625 linija u normi B/G
;ako je polje 1, imacemo 3 linije, jer smo jednu vec napravili
CHORIZ
	BCF PORTB,0
	MOVLW 2
	MOVWF TAJMER
CTIMEx3
	DECFSZ TAJMER,1
	GOTO CTIMEx3
	NOP
	NOP
	MOVLW D'48'
	MOVWF trHOR
	BSF PORTB,0
CLOOPH3
	DECFSZ trHOR,1
	GOTO CLOOPH3
	NOP
	DECFSZ crneLIN,1
	GOTO CHORIZ
	NOP
;8*37+4 linije na kraju=300 linija
;Pocinjemo sa linijama u boji...
CHORIZ1
	BCF PORTB,0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
LIN
	BSF PORTB,0
	NOP
	NOP
	NOP
	MOVLW 0
	XORWF multiR1,W
	NOP
	MOVLW D'37'
	BTFSS STATUS,Z
	GOTO DAVANJE
	MOVWF multiR1
DAVANJE
	MOVLW D'40'
	MOVWF trHOR		;trajanje jedne linije u boji
	MOVF multiR2,W
	MOVWF PORTB		;prikaz boje
	NOP
	NOP
	NOP
	MOVLW D'4'
	MOVWF crneLIN
	NOP
	NOP
	NOP
CBoja1
	DECFSZ trHOR,1
	GOTO CBoja1

	MOVLW Crna
	MOVWF PORTB
	NOP

	DECFSZ multiR1,1
	GOTO CHORIZ1
	NOP

LINK
	BCF PORTB,0
	MOVLW 1
	XORWF multiR2,W
	BTFSC STATUS,Z
	GOTO Prazno
	MOVLW D'4'
	SUBWF multiR2,1		;promena boje
	NOP
	NOP
	NOP
	GOTO LIN
;Za kompletiranje polja dodajemo jos 4 linije...
Prazno				; +4 prazne linije
	NOP			; ukupno 305 linija
	NOP
	NOP
	NOP
	NOP
	NOP
	BSF PORTB,0
	MOVLW D'47'
	MOVWF TAJMER		;trajanje prazne linije
TIM
	DECFSZ TAJMER,1
	GOTO TIM
	NOP
	NOP
	DECFSZ crneLIN,1
	GOTO LINK
	NOP
;Polje je kompletirano. Sledeca linija se koristi
;za ucitavanje promenljivih...
	BCF PORTB,0
	NOP
	NOP
	MOVLW 0
	BTFSC POLJE,0
	MOVLW 1
	MOVWF CARRY
	NOP
	MOVLW D'15'		;za pola linije (polje 2)
	BTFSC POLJE,0
	ADDLW D'24'		;za celu liniju (polje 1)
	MOVWF trHOR
	BSF PORTB,0
	BTFSS POLJE,0
	GOTO NEX
NEX
	NOP
	NOP
CLOOPH5
	DECFSZ trHOR,1
	GOTO CLOOPH5
	RRF CARRY,1
	BTFSS PORTA,2
	GOTO P1P2
	BTFSS PORTA,3
	GOTO P1P2
	NOP
	NOP
	NOP
	NOP
	NOP
	GOTO REDOVI		;nije doslo do promene obrasca

	END