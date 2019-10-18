!----------------------------------------------------------------
      SUBROUTINE INT_TO_CHARA ( 
     M     CHARA , 
     I     INT   , ISTR  , ILONG  )
!
!   ���R�� INT �𕶎��� CHARA(ISTR...) �Ɋi�[����B
!   ILONG �����m�ۂ��A�E�l�߂œ����B
!     �EILONG < 9
!     �E���ɂ� '0' ������  
!
      IMPLICIT NONE
!
      INTEGER,INTENT(IN)      :: ILONG 
      INTEGER,INTENT(IN)      :: ISTR
      INTEGER,INTENT(IN)      :: INT 
      CHARACTER(*),INTENT(INOUT) :: CHARA
!
      INTEGER :: I 
      INTEGER :: IKETA 
      INTEGER :: IWORK
!
! ���̓G���[�`�F�b�N
!
      IF ( ILONG .LT. 0 .OR. ILONG .GT.9 ) THEN 
        WRITE(6,*) 'INT_TO_CHARA ERROR ILONG = ' , ILONG 
        STOP 999
      ENDIF
      IF ( INT .LT. 0 .OR. INT .GE. 10**ILONG ) THEN 
        WRITE(6,*) 'INT_TO_CHARA ERROR INT ILONG = ' , INT , ILONG 
        STOP 999
      ENDIF
!
! �������B'0' ���i�[
!
      DO I=ISTR-1+1,ISTR-1+ILONG 
        CHARA(I:I) = '0' 
      ENDDO 
!
! �����̎擾
!
      IWORK = INT 
      DO I = 1,ILONG 
        IWORK = IWORK / 10 
        IF ( IWORK .EQ.0 ) THEN
          IKETA = I  
          GOTO 1000
        ENDIF 
      ENDDO
!
      WRITE(6,*) 'INT_TO_CHARA ERROR_2 INT ILONG = ' , INT , ILONG 
      STOP 999
!      
 1000 CONTINUE
!
      IF     ( IKETA.EQ.1 ) THEN
        WRITE(CHARA(ILONG+ISTR-1  :ILONG+ISTR-1),'(I1)') INT
      ELSEIF ( IKETA.EQ.2 ) THEN
        WRITE(CHARA(ILONG+ISTR-1-1:ILONG+ISTR-1),'(I2)') INT
      ELSEIF ( IKETA.EQ.3 ) THEN
        WRITE(CHARA(ILONG+ISTR-1-2:ILONG+ISTR-1),'(I3)') INT
      ELSEIF ( IKETA.EQ.4 ) THEN
        WRITE(CHARA(ILONG+ISTR-1-3:ILONG+ISTR-1),'(I4)') INT
      ELSEIF ( IKETA.EQ.5 ) THEN
        WRITE(CHARA(ILONG+ISTR-1-4:ILONG+ISTR-1),'(I5)') INT
      ELSEIF ( IKETA.EQ.6 ) THEN
        WRITE(CHARA(ILONG+ISTR-1-5:ILONG+ISTR-1),'(I6)') INT
      ELSEIF ( IKETA.EQ.7 ) THEN
        WRITE(CHARA(ILONG+ISTR-1-6:ILONG+ISTR-1),'(I7)') INT
      ELSEIF ( IKETA.EQ.8 ) THEN
        WRITE(CHARA(ILONG+ISTR-1-7:ILONG+ISTR-1),'(I8)') INT
      ELSE
        WRITE(6,*) 'INT_TO_CHARA ERROR_3 INT ILONG = ' , INT , ILONG 
        STOP 999
      ENDIF
!
      RETURN
      END