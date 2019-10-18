! cvdate4.F - GSM �ɗR����������v�Z
!
! subroutine CDSET()
!       com_runconf ���Q�Ƃ��ē����e�[�u��������������
! entry GETID(IDIN, IDOUT, KTLAG)
!       IDIN �� KTLAG �������� IDOUT ���o��
! entry GETKT(IDIN1, IDIN2, IFLAG, KTLAG)
!       IDIN1 ���� IDIN2 �܂ł̎��ԍ��� KTLAG ���o��
!       IFLAG =4  ���ԒP�� , 3 ���P��
! entry GETSBD(IDIN, MONS, MONE, WGT) 
!       �����Ƃɗ^������f�[�^�̕�Ԃ̂��߂̏d�݂��v�Z
!
! ID �Ŏn�܂閼�O�̕ϐ��͑傫��5�̐����^�̔z��ŁA�ȉ��̂悤�ɓ������i�[����B
!
!       id(1): ����N
!       id(2): ��
!	id(3): ��
!	id(4): ��
!	id(5): ���g�p (0�ŏ�����)

!==================================================================
! COM_RUNCONF ���W���[���̓��t�����Q�Ƃ��ē����e�[�u��������������B
!
      MODULE CALENDAR 
!
      IMPLICIT NONE
!
      INTEGER,PARAMETER :: IYEARM = 200

      INTEGER,PARAMETER :: 
     +     MON(12) = (/ 31,28,31,30,31,30,31,31,30,31,30,31 /)
!    +     MON(12) = (/ 30,30,30,30,30,30,30,35,30,30,30,30 /)

      INTEGER,PARAMETER :: IYSTR = 1900
!
      INTEGER,SAVE :: MDAY ( IYEARM, 0:25 ) 
!!           0    --- ����
!!           1-12 --- ���̓���
!!          13-24 --- ���̔N�� 1/1 0 ������O���̏I��܂ł̎��Ԑ�
!!          25    --- IYSTR 1/1 0h ���炻�̔N�� 1/1 0h �܂ł̎��Ԑ�
!
      LOGICAL,SAVE :: FIRST = .TRUE.
!
      CONTAINS 
!==========================================================
      SUBROUTINE  CALENDAR_INI
!
      USE COM_RUNCONF_SIB0109 , ONLY : JCN_SIB_ISLSCP, JCN_SIB_ATM_CYCLE 
!
      IMPLICIT NONE
!
      INTEGER :: II
      INTEGER :: J
      INTEGER :: IURU

!
      IF ( FIRST ) THEN
!
        WRITE(6,*) 'CALENDAR_INI : CALENDAR IS SET FROM ' , IYSTR , 
     1              ' TO ' , IYSTR+IYEARM-1 
!
!!  �N MDAY(II,0) �� �e���̓��� MDAY(II,1-12) �̐ݒ�
!
        DO 100 II=1,IYEARM
          MDAY(II,0) = IYSTR + II - 1 
          DO 110 J=1,12
            MDAY(II,J) = MON(J)
 110      CONTINUE
!
!     �[�N����
!       ISLSCP �̏ꍇ�� 1988 �̂�
          IF ( JCN_SIB_ISLSCP .EQ. 1 ) THEN 
            IF ( MDAY(II,0) .EQ. 1988 ) THEN        ! 1988 �����[�N����
              MDAY(II,2) = MDAY(II,2) + 1 
            ENDIF
!       ����ȊO
          ELSE 
!           �������̔N�ŃT�C�N������ꍇ�͋����I�ɔN�����Z�b�g
            IF( JCN_SIB_ATM_CYCLE.NE.0 ) THEN
                  IURU=JCN_SIB_ATM_CYCLE
            ELSE
                  IURU=MDAY(II,0)
            ENDIF
            IF ( (MOD(IURU,400).EQ.0) .OR. 
     -           (MOD(IURU,4).EQ.0.AND.MOD(IURU,100).NE.0) )THEN
              MDAY(II,2) = MDAY(II,2) + 1 
            ENDIF
          ENDIF
 100    CONTINUE
!
!! �O���܂ł̎��Ԃ̐ݒ�
!
        DO 200 II=1,IYEARM
          IF ( II .EQ. 1 ) THEN
            MDAY(II,1+24) = 0
          ELSE
            MDAY(II,1+24) = MDAY(II-1,1+24)       ! �O�X�N�܂�
     1                     + MDAY(II-1,24)        ! �O�N 12/1 �܂�      
     1                     + MDAY(II-1,12)*24     ! �O�N 12 ����
          ENDIF
!
          MDAY(II,1+12) = 0 
!
          DO 210 J=2,12 
            MDAY(II,J+12) = MDAY(II,J-1+12) + MDAY(II,J-1)*24
  210     CONTINUE
  200   CONTINUE
!
#ifdef DEBUG
        WRITE(6,*) '  CDSET : EXAMPLES ARE FOLLOWING. ' 
        DO II =1,IYEARM/10 
          WRITE(6,*) '   YEAR IS ' , MDAY(II,0), 
     1               ' DAYS ARE ' , (MDAY(II,J),J=1,25)
        ENDDO
        DO II =IYEARM*9/10 , IYEARM
          WRITE(6,*) '   YEAR IS ' , MDAY(II,0), 
     1               ' DAYS ARE ' , (MDAY(II,J),J=1,25)
        ENDDO
#endif
! 20050516
! /* DEBUG */
        FIRST = .FALSE. 
!
      ELSE 
        WRITE(6,*) 'CALENDAR_INI : ALREADY SET , SO RETURN '
      ENDIF
!
      RETURN
      END SUBROUTINE CALENDAR_INI
!-----------------------------------------------------------------
      SUBROUTINE CALENDAR_RUN_GETID  ( ID , IDNEW , KTLAG )
!
      implicit none
!
      integer,intent(in)  :: id(5) 
      integer,intent(out) :: idnew(5) 
      integer,intent(in)  :: ktlag
!
      integer  :: ii 
      integer  :: kt1
      integer  :: kt2
      integer  :: m

!
!! ����
!!    ID   (5) :  ���ƂɂȂ����  ( �N, ��, ��, ��, �H )
!!    KTLAG    :  ���ԍ�  
!
!! �o��      
!!    IDNEW(5) :  �v�Z��������  ( �N, ��, ��, ��, �H )
!                 IDNEW = ID  +  KTLAG (HOUR) 
!
!! < �����ݒ� >
!
#ifdef PCHECK
      IF ( FIRST ) THEN
        WRITE(6,*) 'GETID : CALENDAR WAS NOT SET.' 
        STOP 999
      ENDIF  
#endif
!
      IDNEW(1) = ID(1)
      IDNEW(5) = 0                          ! �Ӗ������B
!
!! < ID �� 1/1 ����̒ʎZ���� >             ! �� IYSTR = 1970 �� 
!                                           ! 92/12/31/18 �� + 12 ����
!
      II  = ID(1) - IYSTR + 1               ! ID(1)=1992 -> II= 23
      KT1 = ID(4) + ( ID(3)-1 ) * 24               
     1            + MDAY(II,ID(2)+12)       ! KT1 =18+30*24+334*24
!                                           !               ^^^11/30 �܂� 
!! < IDNEW �� 1/1 ����̒ʎZ���� > 
!
      KT2 = KT1 + KTLAG                     ! KT2 = 6+365*24
!
!! < IDNEW(1-4) �����߂� > 
!
 1100 CONTINUE 
!
      IF ( KT2 .LT. 0 ) THEN   ! �O�̔N ( �܂��͂�����O )             
        IDNEW(1) = IDNEW(1) - 1                    
        II       = II - 1                          
        KT2      = KT2 + ( MDAY(II+1,25) - MDAY(II,25) ) 
        GOTO 1100
!
      ELSEIF ( KT2 .GE. ( MDAY(II+1,25) - MDAY(II,25) )  ) THEN !���N ( �ȍ~ )
        IDNEW(1) = IDNEW(1) + 1 
        II       = II + 1 
        KT2      = KT2  - ( MDAY(II,25) - MDAY(II-1,25) )
        GOTO 1100 
!
      ELSE                      ! ���̔N
        DO 1200 M = 2, 12 
          IF ( KT2 .LT. MDAY(II,M+12) ) THEN   ! ���̑O�̌�
            IDNEW(2) = M-1 
            GOTO 1300 
          ENDIF
 1200   CONTINUE
        IDNEW(2) = 12         
!
 1300   CONTINUE
!
        KT2 = KT2 - MDAY(II,IDNEW(2)+12)       ! ���̌��� 1 ������̎���
        IDNEW(3) = KT2 / 24 + 1 
        IDNEW(4) = MOD ( KT2 , 24 ) 
      ENDIF
!
      RETURN      
      END SUBROUTINE CALENDAR_RUN_GETID
!-----------------------------------------------------------------
      SUBROUTINE CALENDAR_RUN_GETKT ( 
     I     ID    , IDNEW , IFLAG   , 
     O     KTLAG )
!
!! ����
!!    ID   (5) :  ���ƂɂȂ����  ( �N, ��, ��, ��, �H )
!!    IDNEW(5) :  �~��������      ( �N, ��, ��, ��, �H )
!!    IFLAG     :  �t���O. ���ԒP�� 4   ���P�� 3
!!         ������ 1/1 12h �� 1/2 1h �̓����A1/2 14h �̓����͂Ƃ��� 1 ��
!
!! �o��      
!!    KTLAG    :  ���ԍ�  
!                 KTLAG = IDNEW - ID
!
      implicit none
!
      integer,intent(in) :: id(5)
      integer,intent(in) :: idnew(5)
      integer,intent(in) :: iflag
      integer,intent(out):: ktlag
!
      integer :: i1
      integer :: kt1
      integer :: i2
      integer :: kt2
      integer :: kt3
!
#ifdef PCHECK
      IF ( FIRST ) THEN
        WRITE(6,*) 'GETKT : CALENDAR WAS NOT SET.' 
        STOP 999
      ENDIF  
#endif
!
!! < ID �� 1/1 ����̒ʎZ���� >     
!                                   
      I1  = ID(1) - IYSTR + 1       
      KT1 = ID(4) + ( ID(3)-1 ) * 24               
     1      + MDAY(I1,ID(2)+12) 
!
!! < IDNEW �� 1/1 ����̒ʎZ���� >     
!                                   
      I2  = IDNEW(1) - IYSTR + 1       
      KT2 = IDNEW(4) + ( IDNEW(3)-1 ) * 24               
     1         + MDAY(I2,IDNEW(2)+12)
!
!! < ID �� 1/1 �� IDNEW �� 1/1 �Ƃ̎��ԍ� ( �N���Ⴄ�ꍇ 0 �łȂ� ) >
!
      KT3 = MDAY(I2,25) - MDAY(I1,25)
!
!! < KTLAG �̌v�Z > 
!
      IF ( IFLAG .EQ. 4 ) THEN          ! ���ԒP�� 
        KTLAG = KT3 + KT2 - KT1 
      ELSEIF ( IFLAG .EQ. 3 ) THEN
        KTLAG = KT3 / 24 + KT2 / 24 - KT1 / 24 
#ifdef PCHECK
      ELSE 
        WRITE(6,*) 'GETKT : NOT SUPPORT IFLAG = ' , IFLAG 
        STOP 999
#endif
      ENDIF
!
      RETURN        
      END SUBROUTINE CALENDAR_RUN_GETKT       
!-------------------------------------------------------------------
      SUBROUTINE CALENDAR_RUN_GETSBD  (
     I    IDNEW , 
     O    MONS  , MONE , IYEARS , IYEARE , WGT ) 
!
      implicit none
!
      integer,intent(in)  :: idnew(5)
      integer,intent(out) :: mons
      integer,intent(out) :: mone
      integer,intent(out) :: iyears
      integer,intent(out) :: iyeare
      real(8),intent(out) :: wgt
!
      integer :: iy
!
!       �����Ƃɗ^������f�[�^�̕�Ԃ̂��߂̏d�݂��v�Z����B
!       IDNEW ��^����ƁA���O�̌��� (IYEARS �N MONS ��) ��
!       ����̌��� (IYEARE �N MONE ��) �����߁A����2�҂��܂ސ��`��Ԃ�
!       (1.0 - WGT) * (MONS ���̃f�[�^) + WGT * (MONE ���̃f�[�^)
!	�̂悤�� IDNEW �̃f�[�^�𓾂邽�߂̌W�� WGT �����߂�B
!       �����͌�����15���O�ł���A1 ���� 30 ���ł���Ɖ��肳��Ă���B
!
!! WGT ��, MONE �̌��̊���. 
!! �d�ݎ��̂͂�����ƕςȌv�Z�ŋ��߂�. ������ύX. 
!! 
#ifdef PCHECK
      IF ( FIRST ) THEN
        WRITE(6,*) 'GETSBD : CALENDAR WAS NOT SET.' 
        STOP 999
      ENDIF  
#endif
!
      IY = IDNEW(1) - IYSTR + 1 
      IYEARS = IDNEW(1)
      IYEARE = IDNEW(1)
!
      IF ( MDAY(IY,IDNEW(2)) - IDNEW(3) .LE. 15 ) THEN  ! ���̌㔼
        MONS = IDNEW(2) 
        MONE = IDNEW(2)+1 
        WGT  = ( 15 - ( MDAY(IY,IDNEW(2)) - IDNEW(3) ) ) / 30.0D0 
!       WGT  = ( 15 - ( MDAY(IY,IDNEW(2)) - IDNEW(3) ) ) / 30.0 
      ELSE                                              ! ���̑O��
        MONE = IDNEW(2) 
        MONS = IDNEW(2)-1
        WGT  = ( 45 - ( MDAY(IY,IDNEW(2)) - IDNEW(3) ) ) / 30.0D0 
!       WGT  = ( 45 - ( MDAY(IY,IDNEW(2)) - IDNEW(3) ) ) / 30.0 
      ENDIF
!
      IF ( MONE .EQ. 13 ) THEN
        MONE   = 1 
        IYEARE = IYEARE + 1
      ELSEIF ( MONS .EQ. 0 ) THEN
        MONS   = 12 
        IYEARS = IYEARS - 1 
      ENDIF
!
      RETURN
!-------------------------------------------------------------------
      END SUBROUTINE CALENDAR_RUN_GETSBD
      END MODULE CALENDAR
!===================================================================