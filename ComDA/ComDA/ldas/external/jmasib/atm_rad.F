      SUBROUTINE ATM_SWDN_1HR_DEVIDE (
     O     RVISB , RVISD , RNIRB , RNIRD , 
     I     RSHRT , CLD   , ZMEAN_PHY   )
C======================================================================
C...MODIFIED TO 2-D OFFLINE VERSION ON OCT 18 94 BY N.SATO
C======================================================================
C    CALCULATION OF SOLAR ZENITH ANGLE AND SHORTWAVE RADIATION FLUXES
C    FROM DATE/TIME, CLOUDINESS AND SURFACE METEOROLOGICAL CONDITIONS.
C----------------------------------------------------------------------
C
      USE PRM , ONLY : 
     1   IDIM , 
     1   JDIM , 
     1   IRAD , 
     1   JRAD 
!
      IMPLICIT NONE
!
      REAL(8),INTENT(IN)   ::  RSHRT ( IDIM*JDIM )
      REAL(8),INTENT(IN)   ::  CLD   ( IDIM*JDIM )
      REAL(8),INTENT(IN)   ::  ZMEAN_PHY ( IDIM*JDIM )
!
      REAL(8),INTENT(OUT)  ::  RVISB ( IRAD*JRAD )
      REAL(8),INTENT(OUT)  ::  RVISD ( IRAD*JRAD )
      REAL(8),INTENT(OUT)  ::  RNIRB ( IRAD*JRAD )
      REAL(8),INTENT(OUT)  ::  RNIRD ( IRAD*JRAD )
!
      REAL(8),PARAMETER :: ZERO = 0.D0
      REAL(8),PARAMETER :: ONE  = 1.D0
      REAL(8),PARAMETER :: D001 = 1.D-2
!
      REAL(8)  :: DIF_RAT 
      REAL(8)  :: VN_RAT 
!
      INTEGER  :: I
      LOGICAL,SAVE  :: LFIRST 
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        LFIRST = .FALSE.
        WRITE(6,*) 'ATM_RAD 99/11 POCHAKA' 
        IF ( IDIM .NE. IRAD .OR. JDIM.NE.JRAD ) THEN
          WRITE(6,*) 'ATM_RAD ERROR' , IDIM , IRAD , JDIM , JRAD 
          STOP 999
        ENDIF
      ENDIF
C
      DO I=1,IDIM*JDIM
C----------------------------------------------------------------------
C     DOWNWELLING SHORTWAVE RADIATION COMPONENTS : GOUDRIAAN ( 1977)
C----------------------------------------------------------------------
!       COSZ(I) = MAX (0.01745,COSZ(I))
        DIF_RAT = 0.0604D0 / MAX ( D001 , ZMEAN_PHY(I)-0.0223 ) 
     1           + 0.0683D0
        DIF_RAT = MAX( DIF_RAT , ZERO )
        DIF_RAT = MIN( DIF_RAT , ONE  )
C
        DIF_RAT = DIF_RAT + ( 1. - DIF_RAT ) * CLD (I)
        VN_RAT = (  580. - CLD(I)*464. )
     &         / ( (580. - CLD(I)*499. ) + ( 580. - CLD(I)*464. ) )
C
        RVISB(I) = (1.-DIF_RAT) * VN_RAT      * RSHRT(I)
        RVISD(I) = DIF_RAT      * VN_RAT      * RSHRT(I)
        RNIRB(I) = (1.-DIF_RAT) * (1.-VN_RAT) * RSHRT(I)
        RNIRD(I) = DIF_RAT      * (1.-VN_RAT) * RSHRT(I)
!
      ENDDO
!
      RETURN
      END
!===================================================================
      SUBROUTINE ATM_SWDN_6HR (
     I      RDAY      , RSEC     , DELT_ATM , 
     I      GLON      , GLAT     , IMASK    , 
     M      RSWD      , 
     O      SR_FLUX_WORK         )
!
      USE SIBCON , ONLY :
     1      COSZ_MIN_c                      ! �[������ł��邱��
!
      USE PRM , ONLY :
     1      IDIM , JDIM 
      USE MESSAGE, ONLY: MESSAGE_PUT
!
      IMPLICIT NONE
!
      REAL(4),INTENT(INOUT)  :: RSWD(IDIM,JDIM)
      REAL(8),INTENT(IN)     :: RDAY 
      REAL(8),INTENT(IN)     :: RSEC
      REAL(8),INTENT(IN)     :: DELT_ATM
      INTEGER,INTENT(IN)     :: IMASK (IDIM,JDIM)
      REAL(8),INTENT(IN)     :: GLON  (IDIM,JDIM)
      REAL(8),INTENT(IN)     :: GLAT  (IDIM,JDIM)
!
      REAL(8),INTENT(OUT)    :: SR_FLUX_WORK(IDIM,JDIM) 
!
      INTEGER  :: I
      INTEGER  :: J
      INTEGER  :: IST
      INTEGER  :: NSTEPS_6HR 
      REAL(8)  :: DSEC 
!
      REAL(8)  :: COSZ        (IDIM,JDIM) 
      REAL(8)  :: COSZ_SUM    (IDIM,JDIM) 
!
!     REAL(8),PARAMETER :: RSWD_MIN = 1.D-6  
!
!  ���� 6 ���Ԃ̕��ϒZ�g�t���b�N�X�i��̓[���j����A
!  SR_FLUX_WORK * COSZ ���t���b�N�X�ɂȂ�悤�� SR_FLUX_WORK ���v�Z����B
!
! ----------------------
! > 6 ���Ԃ̃X�e�b�v�� < 
! ----------------------
!
      NSTEPS_6HR = (6*3600+1) / DELT_ATM 
!
! ------------------
! > �f�[�^�`�F�b�N <
! ------------------
!   -1 �ȉ�����������͂˂�B-1<rswd<0 �Ȃ�΃��b�Z�[�W��f���� 0 �ɂ���B
!
      DO j=1,jdim
      DO i=1,idim
        if     ( rswd(i,j) .lt. -1. ) then 
          write(6,*) 'rswd atm_swdn_6hr heavy warning' , 
     1               i , j , rswd(i,j) , 'is modified to 0'
        elseif ( rswd(i,j) .lt. 0.  ) then 
          write(6,*) 'rswd atm_swdn_6hr warning' , 
     1               i , j , rswd(i,j) , 'is modified to 0'
          rswd(i,j) = 0.
        endif
      enddo 
      enddo 
!
! --------------------------------------------------
! > 6 ���Ԃ̊Ԃ̊e�X�e�b�v�ł̓V���p�̌v�Z�A���ώZ <
! --------------------------------------------------
!
      COSZ_SUM (:,:) = 0.D0
!
      DO IST = 1,NSTEPS_6HR
        DSEC = RSEC + DELT_ATM / 86400.D0 * ( IST - 0.5D0 ) 
!
        CALL ATM_SUNANG ( 
     I      RDAY     , DSEC    , 
     I      GLON     , GLAT    , 
     O      COSZ         )
!
        DO J=1,JDIM
        DO I=1,IDIM
          IF ( COSZ(I,J) .GE. COSZ_MIN_c ) THEN
            COSZ_SUM (I,J) = COSZ_SUM (I,J) + COSZ(I,J)    ! �V���p�ώZ
          ENDIF
        ENDDO
        ENDDO
      ENDDO
!
!   (3) �f�[�^�`�F�b�N
!
      DO J=1,JDIM
      DO I=1,IDIM
!
!         �Z�g������̂ɓV���p�̘a�����Ȃ�΁A�x���A�Z�g�̓[����
        IF     (       RSWD (I,J)   .GT. 0.
     1           .AND. COSZ_SUM(I,J).EQ. COSZ_MIN_c 
     1           .AND. IMASK(I,J)   .NE. 0        ) THEN
          CALL MESSAGE_PUT('ATM_SWDN_6HR WARNING RSWD >0 COSZ=0')
#         if defined(CHECK) || defined(DEBUG)
          WRITE(6,*) I, J, RSWD(I, J), COSZ_SUM(I, J)
#         endif
          RSWD(I,J) = 0.
!
!         �Z�g���Ȃ��̂ɓV���p�̘a�����Ȃ�΁A�x���B
        ELSEIF (       RSWD (I,J)    .LE. 0.
     1           .AND. COSZ_SUM(I,J) .GE. COSZ_MIN_c 
     1           .AND. IMASK(I,J)    .NE. 0    ) THEN
          CALL MESSAGE_PUT('ATM_SWDN_6HR WARNING RSWD =0 COSZ>0')
#         if defined(CHECK) || defined(DEBUG)
          WRITE(6,*) I, J, RSWD(I, J), COSZ_SUM(I, J)
#         endif
        ENDIF
      ENDDO
      ENDDO
!
!   (4) S/�� �̌v�Z
!       SR_FLUX_WORK * COSZ ���t���b�N�X�ɂȂ�悤�ɂ���B
!
!       cosz_sum �����܂�ɏ������Ƃ��́A�Z�g���ɂ��Ă��܂��B
!       �Q�͖����낤�B�����B
!
!       RSWD �͓�������ł���Ԃ��܂߂� 6 ���Ԃ̕��ρB
!       ����āA�Z�g���v�� RSWD*NSTEPS_6HR �ŋ��߂Ă����B
!       COSZ/COSZ_SUM �́A���̂����̔z�����\���B
!
      SR_FLUX_WORK(:,:) = 0.D0 
      DO J=1,JDIM
      DO I=1,IDIM
        IF ( COSZ_SUM(I,J).GE.COSZ_MIN_c ) THEN
          SR_FLUX_WORK(I,J) = RSWD(I,J) * NSTEPS_6HR
     1                        / COSZ_SUM(I,J) 
        ENDIF
      ENDDO
      ENDDO
!
      RETURN
      END SUBROUTINE ATM_SWDN_6HR 
!================================================================
      SUBROUTINE ATM_SWDN_1HR (
     I    RDAY      , RSEC     , DELT_ATM , 
     I    SR_FLUX_WORK    ,
     I    GLON      , GLAT     , 
     O    NSTEPS_RAD,  
     O    RSHRT     ,  ZMEAN_PHY   )
!
!  �Z�g���ˌv�Z�X�e�b�v�̏��� 
!     ���̒Z�g���ˌv�Z�܂ł̕��ς̓V���p�E�Z�g���� 4 �������v�Z����B
!
      USE PRM , ONLY :
     1   IDIM  , 
     1   JDIM 
!
      USE COM_RUNCONF_SIB0109 , ONLY :
     1   JCN_IWL_SKIP            !  �}1 �Ȃ�� ���X�e�b�v���ˌv�Z
!
      USE SIBCON , ONLY :
     1      COSZ_MIN_C                      ! �[������ł��邱��
!
      IMPLICIT NONE
!
      REAL(8),INTENT(IN)    :: RDAY 
      REAL(8),INTENT(IN)    :: RSEC
      REAL(8),INTENT(IN)    :: DELT_ATM
      REAL(8),INTENT(IN)    :: SR_FLUX_WORK(IDIM,JDIM)
      REAL(8),INTENT(IN)    :: GLON  (IDIM,JDIM)
      REAL(8),INTENT(IN)    :: GLAT  (IDIM,JDIM)
      REAL(8),INTENT(OUT)   :: ZMEAN_PHY   (IDIM,JDIM)
      REAL(8),INTENT(OUT)   :: RSHRT       (IDIM,JDIM)
!
      INTEGER,INTENT(OUT)   :: NSTEPS_RAD
!
      REAL(8)               :: COSZ     (IDIM,JDIM) 
      REAL(8)               :: COSZ_SUM (IDIM,JDIM) 
      INTEGER               :: ICOSZ_SUM(IDIM,JDIM) 
      INTEGER               :: IST
      REAL(8)               :: DSEC
      INTEGER               :: I
      INTEGER               :: J
!
!  �X�e�b�v��
!
      IF ( ABS(JCN_IWL_SKIP).EQ.1 ) THEN   
!                                                       ! ���X�e�b�v���ˌv�Z
        NSTEPS_RAD = 1 
      ELSE                                            ! �ꎞ�ԂɈ�x
        NSTEPS_RAD = 3601 / DELT_ATM 
      ENDIF  
!
      COSZ_SUM  (:,:) = 0.D0
      ICOSZ_SUM (:,:) = 0
!
      DO IST = 1,NSTEPS_RAD
        DSEC = RSEC + DELT_ATM / 86400.D0 * ( IST - 0.5D0 ) 
!
        CALL ATM_SUNANG ( 
     I    RDAY     , DSEC    , 
     I    GLON     , GLAT    , 
     O    COSZ         )
!
        DO J=1,JDIM
        DO I=1,IDIM
          IF ( COSZ(I,J) .GE. COSZ_MIN_c ) THEN
            COSZ_SUM (I,J) = COSZ_SUM (I,J) + COSZ(I,J)    ! �V���p�ώZ
            ICOSZ_SUM(I,J) = ICOSZ_SUM(I,J) + 1 
          ENDIF
        ENDDO
        ENDDO
      ENDDO
!
      CALL RESET ( ZMEAN_PHY , IDIM*JDIM )
      CALL RESET ( RSHRT     , IDIM*JDIM )
      DO J=1,JDIM
      DO I=1,IDIM
        IF ( COSZ_SUM(I,J) .GE. COSZ_MIN_c ) THEN
          ZMEAN_PHY(I,J) = COSZ_SUM(I,J) / ICOSZ_SUM(I,J) ! �������̕���
          RSHRT    (I,J) = SR_FLUX_WORK(I,J)              ! ����܂ޕ��� 
     1                   * COSZ_SUM(I,J) / NSTEPS_RAD
        ENDIF
      ENDDO
      ENDDO
!
      RETURN
      END SUBROUTINE ATM_SWDN_1HR 