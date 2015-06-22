; TP1 : Repr�sentation normalis�e des nombres flottants 
; convertisseur de nombres flottants d�cimaux vers une forme normalis�e
; Mathieu Pronovost
; PROM18118300
; 14 f�vrier 2012

          lda 0,i
          sta position,d
          sta zeroDebu,d
          sta pos0neg,d
          sta pointPos,d
          sta zeroFin,d
          sta expNeg,d
         
          lda -1,i
          sta exposant,d 

          stro entreMsg,d      ; print(entreMsg) 

; boucle while qui permet de traiter chaque caract�re l'un apr�s l'autre
readChar: lda 0,i              ; do {
          chari c,d                

; si position est �gal � 0 :
; - affiche sortiMsg
; - garde en m�moire si le premier caract�re est '-'
; - garde en m�moire si le premier caract�re est '0'
; - affiche un message d'erreur si le premier caract�re est '\n'
; - garde en m�moire la valeur du premier caract�re
          lda position,d
          cpa 0,i
          brne finPos0         ;   if (position == 0) {
          stro sortiMsg,d
          ldbytea c,d
          stbytea premierC,d   ;     premierC = c
          cpa '-',i
          brne pos0zero        ;     if (c == '-') {
          lda 1,i      
          sta pos0neg,d        ;       pos0neg = 1   
          lda exposant,d
          suba 1,i
          sta exposant,d       ;       exposant--   
pos0zero: ldbytea c,d          ;     }
          cpa '0',i            
          brne pos0n           ;     if (c == '0') {
          lda 1,i      
          sta zeroDebu,d       ;       zeroDebu = 1 
pos0n:    ldbytea c,d          ;     }
          cpa '\n',i           
          brne finPos0         ;     if (c == '\n') {
          br erreur            ;       erreur()
;                                    }
;                                  }

; si position est �gal � 1 :
; - affiche un message d'erreur si le premier caract�re est '-'
;   et le deuxi�me caract�re est '\n'
; - met zeroDebu � 1 si le premier caract�re �tait '-' et
;   celui-ci est '0'
finPos0:  lda position,d
          cpa 1,i
          brne finPos1         ;   if (position == 1) {   
          lda pos0neg,d
          cpa 1,i
          brne finPos1         ;     if (pos0neg == 1) {
          ldbytea c,d
          cpa '\n',i
          brne pos1zero        ;       if (c == '\n') {
          br erreur            ;         erreur()
pos1zero: cpa '0',i            ;       } else if (c == '0') {
          brne finPos1
          lda 1,i
          sta zeroDebu,d       ;       zeroDebu = 1
;                                    }
;                                  }

; si le caract�re est compris entre 1 et 9 :
; - met zeroDebu � 0 permettant de savoir que la suite de 0
;   au d�but de la cha�ne est termin�e
; - si la position du point est �gale � 1 lorsque zeroDebu est
;   mis � 0, cela veut dire que c'est un exposant n�gatif,
;   alors pour pouvoir calculer la valeur de l'exposant � la fin,
;   on attribue la valeur actuelle de position � expNeg
finPos1:  ldbytea c,d
          cpa '1',i
          brlt fin1et9         ;   if (c >= 1) {
          ldbytea c,d
          cpa '9',i
          brgt fin1et9         ;     if (c <= 9) {
          lda 0,i
          sta zeroDebu,d       ;       zeroDebu = 0
          lda pointPos,d       ;     
          cpa 1,i
          brne fin1et9         ;       if (pointPos == 1) {
          lda position,d
          sta expNeg,d         ;         expNeg = position
;                                      }
;                                    }
;                                  }

; si le caract�re est �gal � '.' :
; - compte le nombre de '.' et affiche un message d'erreur
;   s'il y a plus d'un point
; - garde en m�moire la position du '.' ce qui permettra
;   de calculer l'exposant � la fin
fin1et9:  ldbytea c,d
          cpa '.',i           
          brne pointFin        ;   if (c == '.') {
          lda nbPoints,d
          adda 1,i
          sta nbPoints,d       ;     nbPoints++
          lda nbPoints,d
          cpa 1,i              ;     if (nbPoints > 1) {
          brgt erreur          ;       erreur()
          lda position,d       ;     } else { 
          sta pointPos,d       ;       pointPos = position
;                                    }
;                                  }

; si la valeur du caract�re est < '0' :
; - affiche un message d'erreur sauf si :
;   - c'est un '\n'
;   - c'est un '.'
;   - c'est le premier caract�re et qu'il est �gal � '-'
pointFin:  ldbytea c,d
           cpa '0',i
           brge erLowFin       ;   if (c < '0') {
           cpa '\n',i          ;    
           breq erLowFin       ;     if (c == '\n') {
           cpa '.',i           ;       erLowFin()
           breq erLowFin       ;     } else if (c == '.') {
           cpa '-',i           ;       erLowFin()
           brne erreur         ;     } else if (c == '-') {  
           lda position,d      ;       if (position == 0) {
           cpa 0,i             ;         erLowFin()  
           brne erreur         ;     }
;                                    erreur()
;                                  }

; si la valeur du caract�re est > '9' :
; - affiche un message d'erreur
erLowFin:  ldbytea c,d
           cpa '9',i
           brle errUpFin       ;   if (c > '9') { 
           br erreur           ;     erreur()
;                                  }
 
; afin de ne pas afficher les '0' en fin de cha�ne :
; - v�rifie si le caract�re en traitement est '0' et :
;   - v�rifie si ce ne sont pas des '0' en d�but de cha�ne (zeroDebu == 0)
;   - incr�mente zeroFin
errUpFin: lda zeroDebu,d
          cpa 1,i
          breq comp0fin        ;   if (zeroDebu != 1) {
          ldbytea c,d
          cpa '0',i
          brne comp0fin        ;     if (c == '0') {
          lda zeroFin,d
          adda 1,i
          sta zeroFin,d        ;       zeroFin++
;                                    }
;                                  }

; afin d'afficher les '0' en milieu de cha�ne :
; - v�rifie que zeroFin est sup�rieur � 0
; - v�rifie que le caract�re en traitement est situ� entre '1' et '9'
;   (si le caract�re �tait '\n', cela voudrait dire que ce sont des '0'
;    de fin de cha�ne, et non des '0' de milieu de cha�ne)
; - affiche des '0' et d�cr�mente zeroFin tant que zeroFin n'est pas �gal � 0
comp0fin: lda zeroFin,d
          cpa 0,i
          breq mid0fin
          ldbytea c,d
          cpa '1',i
          brlt mid0fin         ;   if (c >= 1) {
          ldbytea c,d
          cpa '9',i
          brgt mid0fin         ;     if (c <= 9) {
loop:     lda zeroFin,d        ;       while (zeroFin > 0) {
          cpa 0,i
          breq mid0fin
          charo '0',i          ;         print('0')
          suba 1,i
          sta zeroFin,d        ;         zeroFin--
          lda nbPoints,d
          cpa 1,i
          brne loop            ;         if (nbPoints == 1) {
          lda exposant,d
          suba 1,i             ;           exposant--
          sta exposant,d       ;         }
          br loop              ;       }
;                                    }
;                                  }

; afin d'afficher le '0' et le '.' au d�but :
; - si le premier caract�re est '0' et le deuxi�me est '\n' :
;   - afficher '0' et terminer le programme
; - afficher "0." si le nombre est positif
; - afficher "-0." si le nombre est n�gatif
; par la suite, affiche le premier caract�re si :
; - ce n'est pas un '-'
; - ce n'est pas un '0'
; - affiche un message d'erreur si c'est un '.'
mid0fin:  lda position,d
          cpa 1,i
          brne zerPtFin        ;   if (position == 1) {
          lda pos0neg,d
          cpa 1,i              ;     if (pos0neg = 1) {
          brne zerPoint        ;       print('-')   
          charo '-',i          ;     }
zerPoint: charo '0',i          ;     print('0')
          ldbytea c,d
          cpa '\n',i
          brne point           ;     if (c == '\n') {
          ldbytea premierC,d 
          cpa '0',i
          brne point           ;       if (premierC == '0') {
          stop                 ;         stop()
;                                      }
;                                    }
point:    charo '.',i          ;     print('.')
          ldbytea premierC,d
          cpa '-',i
          breq zerPtFin        ;     if (premierC != '-') {
          cpa '0',i
          breq zerPtFin        ;       if (premierC != '0') {
          cpa '.',i            ;         if (premierC == '.') {
          breq erreur          ;           erreur()
          charo premierC,d     ;         }
;                                      }
;                                      print(premierC)                                      
;                                    }
;                                  }

; ajuste la valeur de l'exposant en prenant compte diff�rents facteurs
zerPtFin: lda zeroDebu,d
          cpa 1,i
          breq nonZero         ;   if (zeroDebu != 1) {
          lda nbPoints,d
          cpa 0,i
          brne nonZero         ;     if (nbPoints == 0) {
          lda zeroFin,d
          cpa 1,i              ;       if (zeroFin < 1) {
          brge nonZero
          lda exposant,d       
          adda 1,i
          sta exposant,d       ;         exposant++
;                                      }
;                                    }
;                                  }

nonZero:  lda nbPoints,d
          cpa 1,i
          brne nonPoint        ;   if (nbPoints == 1) {
          lda zeroFin,d
          cpa 1,i
          brne nonPoint        ;     if (zeroFin == 1) {
          lda exposant,d
          adda 1,i
          sta exposant,d      ;        exposant++
;                                    }
;                                  }

nonPoint: lda nbPoints,d
          cpa 0,i
          brne unPoint        ;   if (unPoint == 0) {
          lda zeroFin,d
          cpa 1,i
          brlt unPoint        ;     if (zeroFin >= 1) {
          lda exposant,d
          adda 1,i
          sta exposant,d      ;       exposant++
;                                   }
;                                 } 

; affiche le caract�re si :
; - ce n'est pas un z�ro en d�but de cha�ne (zeroDebu == 0)
; - ce n'est pas un z�ro en fin de cha�ne (zeroFin == 0)
; - ce n'est pas un '.'
; - ce n'est pas un '-'
unPoint:  lda position,d
          cpa 1,i
          brlt finPrint        ;   if (position >= 1) {
          lda zeroDebu,d
          cpa 1,i
          breq finPrint        ;     if (zeroDebu != 1) {
          lda zeroFin,d
          cpa 1,i
          brge finPrint        ;       if (zeroFin == 0) {
          ldbytea c,d
          cpa '.',i
          breq finPrint        ;         if (c != '.') {
          cpa '-',i
          breq finPrint        ;           if (c != '-') {
          cpa '\n',i
          breq finPrint
          charo c,d            ;             print(c)
;                                          }
;                                        }
;                                      }
;                                    }
;                                  }

; incr�mente position afin de savoir o� l'on est rendu 
; dans la lecture de la cha�ne de caract�res
finPrint: lda position,d 
          adda 1,i 
          sta position,d       ; position++

          ldbytea c,d
          cpa '\n',i 
          brne readChar        ; } while (A != '\n'); 

; affiche l'exposant s'il n'est pas �gal � 0
          lda exposant,d
          cpa 0,i
          breq fin             ; if (exposant != 0) {
          lda expNeg,d         ;   if (expNeg == 3) {
          cpa 3,i              ;     fin()
          breq fin             ;   }
          charo 'e',i          ;   print ('e')
          lda expNeg,d
          cpa 0,i
          breq expPos          ;   if (expNeg != 0) {
          suba 2,i             ;     expNeg = expNeg - 2
          sta expNeg,d         
          charo '-',i          ;     print('-')
          deco expNeg,d        ;     print(expNeg)
          br fin               ;     fin()
;                                  }
expPos:   deco exposant,d      ;   print (exposant)
;                                }
fin:      stop

; affiche un message d'erreur et quitte le programme
erreur:   stro ereurMsg,d  
          stop

; constantes 
entreMsg: .ascii "entr�e: \x00"
sortiMsg: .ascii "sortie: \x00"
ereurMsg: .ascii "Erreur\x00"

; variables 
c:        .block 2             ; caract�re lu
premierC: .block 2             ; valeur du premier caract�re
position: .block 2             ; nombre incr�ment� � chaque tour de boucle
zeroDebu: .block 2             ; garde en m�moire si les premiers caract�res sont des '0'
zeroFin:  .block 2             ; permet de savoir s'il y a des '0' � la fin
pos0neg:  .block 2             ; garde en m�moire si le premier caract�re est n�gatif
pointPos: .block 2             ; position du point
nbPoints: .block 2             ; nombre de points
exposant: .block 2             ; valeur de l'exposant
expNeg:   .block 2             ; valeur � utiliser si l'exposant est n�gatif
.end