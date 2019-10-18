!  �@�\ : ��C���[�ł̒��g���˃t���b�N�X����ˊi�q���痤�ʊi�q�ɋl�ߑւ��B
!         ���g���ˌv�Z�X�e�b�v�̂�
!  99/05/xx �ۍ␪�G
!  99/07/21 �ۍ␪�G �ϐ����A�T�u���[�`�����ύX
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE RAD_SHRT_RGRD_2_SIBGRD (
     I IMSKLT_RX , IMSKLT_RY , NMAX      ,
     I RVISB     , RVISD     , RNIRB     , RNIRD     , 
     O RAD_SHRT_INTO_SIB   )
!
!  �@�\ : ��C���[�ł̒��g���˃t���b�N�X����ˊi�q���痤�ʊi�q�ɋl�ߑւ��B
!         ���g���ˌv�Z�X�e�b�v�̂�
!
!  ���� : �]���Ƃ̑Ή��Ƃ��ẮADLWB �������B����͂��Ƃ��ƑS�ʃf�[�^����
!         �����߁B
!
      USE PRM , ONLY : 
     1    IRAD  , 
     1    JRAD  , 
     1    JLPHY  
!
      USE SIBPRM , ONLY :
     1    IDX    ,
     1    IVN    ,
     1    IBD   
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER,INTENT(IN)   ::  IMSKLT_RX ( IDX )      ! SiB -> ����
      INTEGER,INTENT(IN)   ::  IMSKLT_RY ( IDX )
      INTEGER,INTENT(IN)   ::  NMAX 
!
      REAL(8),INTENT(IN)   ::  RVISB   ( IRAD , JRAD /JLPHY )   
      REAL(8),INTENT(IN)   ::  RVISD   ( IRAD , JRAD /JLPHY)
      REAL(8),INTENT(IN)   ::  RNIRB   ( IRAD , JRAD /JLPHY)
      REAL(8),INTENT(IN)   ::  RNIRD   ( IRAD , JRAD /JLPHY)
!
! OUTPUT
!
      REAL(8),INTENT(OUT)  ::  
     1   RAD_SHRT_INTO_SIB ( IDX, IVN, IBD ) ! ��C���[��������
!
! WORK
      INTEGER              :: N
      INTEGER              :: IR
      INTEGER              :: JR
!
      LOGICAL LFIRST
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'RAD_SHRT_RGRD_2_SIBGRD 99/07 POCHAKA '
        LFIRST = .FALSE.
      ENDIF 

!
      DO 1000 N=1,NMAX
        IR  = IMSKLT_RX(N)
        JR  = IMSKLT_RY(N)
        RAD_SHRT_INTO_SIB(N,1,1) = RVISB (IR,JR)               ! ���E���B
        RAD_SHRT_INTO_SIB(N,1,2) = RVISD (IR,JR)               ! ���E�U��
        RAD_SHRT_INTO_SIB(N,2,1) = RNIRB (IR,JR)               ! �ߐԁE���B
        RAD_SHRT_INTO_SIB(N,2,2) = RNIRD (IR,JR)               ! �ߐԁE�U��
 1000 CONTINUE
!
      RETURN
      END
! ===============================================================
      SUBROUTINE RAD_LONG_RGRD_2_SIBGRD (
     I IMSKLT_RX , IMSKLT_RY , NMAX      ,
     I DLWB      , 
     O RAD_LONG_INTO_SIB   )
!
!  �@�\ : ��C���[�ł̒��g���˃t���b�N�X����ˊi�q���痤�ʊi�q�ɋl�ߑւ��B
!         ���g���ˌv�Z�X�e�b�v�̂�
!
!  ���� : �]���Ƃ̑Ή��Ƃ��ẮADLWB �������B����͂��Ƃ��ƑS�ʃf�[�^����
!         �����߁B
!
      USE PRM , ONLY : 
     1    IRAD  , 
     1    JRAD  ,
     1    JLPHY 
!
      USE SIBPRM , ONLY :
     1    IDX    
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER,INTENT(IN)   ::  IMSKLT_RX ( IDX )      ! SiB -> ����
      INTEGER,INTENT(IN)   ::  IMSKLT_RY ( IDX )
      INTEGER,INTENT(IN)   ::  NMAX 
!
      REAL(8),INTENT(IN)   ::  DLWB   ( IRAD , JRAD/JLPHY )   
!
! OUTPUT
!
      REAL(8),INTENT(OUT)  ::  
     1   RAD_LONG_INTO_SIB ( IDX ) ! ��C���[��������
!
! WORK
      INTEGER              :: N
      INTEGER              :: IR
      INTEGER              :: JR
!
      LOGICAL LFIRST
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'RAD_LONG_RGRD_2_SIBGRD 99/07 POCHAKA '
        LFIRST = .FALSE.
      ENDIF 
!
      DO 1000 N=1,NMAX
        IR  = IMSKLT_RX(N)
        JR  = IMSKLT_RY(N)
        RAD_LONG_INTO_SIB(N) = DLWB (IR,JR) 
 1000 CONTINUE
!
      RETURN
      END