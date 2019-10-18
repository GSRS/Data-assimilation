! �Ⴢ�j�^�p
!   �Œ肵���[���Ȃǂł̉��x�������j�^�B
!   ���x�]���͂��������ɁA���`���}
!   �߂�ǂ������̂ō������͂��Ȃ��B
!
!   ������
!     �E�w�背�x�����ŉ��w�̒������������̏ꍇ
!         --> �ŉ��w�̉��x            
!     �E�w�背�x�����ŏ�w�̒�����������̏ꍇ
!         --> �ŏ�w�̉��x�ƃX�L���Ő��`���}            
!
      SUBROUTINE SNOW_MONIT_FIXED_DEPTH (
     I    NMAX   , NMAX_01 , DELT_SNOW ,
     I    CVR_SNW_INV_NEXT  , 
     I    INFO_SNOW_NEXT    , 
     I    TMP_SNOW_NEXT     , TMP_SNSK_NEXT     , 
     I    WTR_SNOW_NEXT     , GLA_SNOW_NEXT     , 
     I    DEP_SNOW_NEXT  )
!
      USE SIBPRM , ONLY :
     I    IDX  , 
     I    ISN  
!
      USE SIB_MONIT , ONLY : MONIT_SIB , INS, 
     1                       IMONIT_LEVEL, IMONIT_ALL
!
      IMPLICIT NONE
!
! ����
!
      INTEGER,INTENT(IN)  :: NMAX  
      INTEGER,INTENT(IN)  :: NMAX_01(3) 
      INTEGER,INTENT(IN)  :: INFO_SNOW_NEXT(IDX) 
!
      REAL(8),INTENT(IN)  :: DELT_SNOW 
      REAL(8),INTENT(IN)  :: TMP_SNOW_NEXT     (IDX,ISN) 
      REAL(8),INTENT(IN)  :: TMP_SNSK_NEXT     (IDX) 
      REAL(8),INTENT(IN)  :: CVR_SNW_INV_NEXT  (IDX) 
      REAL(8),INTENT(IN)  :: GLA_SNOW_NEXT     (IDX,ISN) 
      REAL(8),INTENT(IN)  :: WTR_SNOW_NEXT     (IDX,ISN) 
      REAL(8),INTENT(IN)  :: DEP_SNOW_NEXT     (IDX,ISN+1) 
!
! �[���Ȃǂ̏��
!
      INTEGER,PARAMETER :: NUM_DEPTH  = 3
      INTEGER,PARAMETER :: NUM_WEIGHT = 3
      REAL(8),SAVE      :: FIXED_DEPTH  ( NUM_DEPTH  ) 
      REAL(8),SAVE      :: FIXED_WEIGHT ( NUM_WEIGHT )
!
! WORK
      REAL(8)           :: CVR       ( IDX )   ! �w��ʂ̗L1��0�B
      REAL(8)           :: DAT       ( IDX )   ! ���}���ꂽ�f�[�^
!
      REAL(8)           :: TMP_SNSK  ( IDX ) 
!
      REAL(8)           :: DEPTH_HAF ( IDX )  
      REAL(8)           :: DEPTH_TMP ( IDX )
!
      REAL(8)           :: WEIGHT_SNOW ( IDX,ISN )  
      REAL(8)           :: WEIGHT_HAF ( IDX )  
      REAL(8)           :: WEIGHT_TMP ( IDX )
!
      INTEGER           :: KLEV_SNOW ( IDX )  
      INTEGER           :: KLEV      ( IDX )  
!
      REAL(8)           :: DEL 
      REAL(8)           :: WGT
!
      INTEGER           :: K_BOT
      INTEGER           :: K_TOP
      INTEGER           :: K
      INTEGER           :: KK
      INTEGER           :: I 
!
#ifdef MONYOS
      CHARACTER( 7)  :: CMARK 
      real(8),parameter :: one = 1.D0
#endif
!
      DATA FIXED_DEPTH  / 0.1D0 , 1.0D0 , 2.0D0 / 
!     DATA FIXED_DEPTH  / 0.02D0 , 1.0D0 , 2.0D0 / 
      DATA FIXED_WEIGHT / 0.3D0 , 3.D0  , 6.D0 / 
!
!                          -1  �ᖳ��
!                           1  01
!                           3  1 �w       �i����j       
!                           4  2 �w        (���� 1 �w , �V�� 1 �w)             
!                           5  2 �w        (���� 2 �w )
!                           6  2 �w        (���� 2 �w , �V�� 1 �w)             
!                           7  2 �w        (���� 3 �w )
!                           8  2 �w        (���� 3 �w , �V�� 1 �w)             
!
!    --------------------------------------------------------------
!
! �S�Ă̏o�͂�����ꍇ�ȊO�͑����^�[�� ( 2001/12/05 ���� ) 
!
      IF ( IMONIT_LEVEL .LT. IMONIT_ALL ) RETURN
!
! ==========
! >> ���� <<
! ==========
!
! ----------------
! > ��w���̌v�Z <       
! ----------------
!
      DO I=1,NMAX
        KLEV_SNOW(I) = MAX(INFO_SNOW_NEXT(I),0)  
        IF ( INFO_SNOW_NEXT(I).EQ.0 ) THEN
          KLEV_SNOW(I) = 1 
        ENDIF 
      ENDDO
!
      DO K=1,ISN
      DO I=1,NMAX
        WEIGHT_SNOW(I,K) = GLA_SNOW_NEXT(I,K) + WTR_SNOW_NEXT(I,K) 
      ENDDO
      ENDDO
!
!   01 �̏ꍇ�͐ϐ�핢�����l��
!     GLA_* �� WTR_* �͐�̂��镔���Ȃ��������ς����d�݂ł���B
!     ��̂���ʐς����ŕ��ς�����̏d�݂́A��������傫���B
!
      DO I=1,NMAX
        IF ( INFO_SNOW_NEXT(I).EQ.0 ) THEN
          WEIGHT_SNOW(I,1) = WEIGHT_SNOW(I,1) * CVR_SNW_INV_NEXT(I)
        ENDIF
      ENDDO 
!
! --------------------
! > �\�ʐቷ�x�̐ݒ� <       
! --------------------
!  �������Ƃ��� 0 �w��������X�L�����x�͂Ȃ��̂ŁA���w�̉��x�ɂ���B
!  �Ƃ������Ƃ́A�{�� snow_main �̐^�ʖڂȌv�Z�̈�ԍŌ�ł��ׂ���?
!
      TMP_SNSK (:) = 1.D40 
      DO I=1,NMAX
        IF     ( KLEV_SNOW(I).GT.0 ) THEN
          IF     ( I.LT.NMAX_01(2) ) THEN  
            TMP_SNSK (I) = TMP_SNOW_NEXT (I,1)
          ELSE
            TMP_SNSK (I) = TMP_SNSK_NEXT (I) 
          ENDIF
        ENDIF
      ENDDO
!
! ================
! >> �[���ʏ�� <<   
! ================
!
      DO KK=1,NUM_DEPTH
!
        DAT       (:) = 0.D0 
        CVR       (:) = 0.D0        
!
        DEPTH_TMP (:) = 0.D0    
        DEPTH_HAF (:) = 0.D0    
        KLEV      (:) = 0 
!
!  ----------------------
!  > �z���郌�x���̌v�Z <
!  ----------------------
!      �w�背�x�����܂ޑw        KLEV 
!      ���̑w�܂ł̐[��          DEPTH
!      ���̑w�̒������܂ł̐[��  DEPTH_HAF 
!
        DO K=1,ISN
        DO I=1,NMAX 
          DEPTH_TMP(I) = DEPTH_TMP(I) + DEP_SNOW_NEXT(I,K)
          IF (       KLEV(I) .EQ. 0 
     1         .AND. DEPTH_TMP(I) .GT. FIXED_DEPTH(KK) )  THEN
            KLEV(I) = K 
!           DEPTH    (I) = DEPTH_TMP(I) 
            DEPTH_HAF(I) = DEPTH_TMP(I) - DEP_SNOW_NEXT(I,K)/2 
          ENDIF
        ENDDO
        ENDDO
!
!  --------------------------
!  > ���}�Ɏg�����x���̐ݒ� <
!  --------------------------
!
        DO I=1,NMAX
        IF ( KLEV(I).GT.0 ) THEN                     ! ���}���郌�x���̂�
!
          CVR(I) = 1.
!
!   ��Ɖ��̃��x���̌���
!
          IF ( FIXED_DEPTH(KK) .GT. DEPTH_HAF(I) ) THEN   ! ���̑w�Ɠ��}
            K_BOT = KLEV(I) + 1 
            K_TOP = KLEV(I) 
          ELSE                                            ! ��̑w�Ɠ��} 
            K_BOT = KLEV(I) 
            K_TOP = KLEV(I) - 1 
          ENDIF
!
!    ���}
!
          IF     ( K_BOT .EQ. KLEV_SNOW(I)+1 ) THEN  ! �ŉ��w�̒�����艺
            DAT (I) = TMP_SNOW_NEXT(I,KLEV_SNOW(I)) 
!
          ELSEIF ( K_TOP .EQ. 0 ) THEN                ! �ŏ�w�̒�������
            DAT (I) =   
     1            + TMP_SNSK(I)
     1                * ( 1 - FIXED_DEPTH(KK) / DEPTH_HAF(I) ) ! ������̋��� 
     1            + TMP_SNOW_NEXT(I,1) 
     1                *  FIXED_DEPTH(KK)      / DEPTH_HAF(I)   ! �ォ��̋���
!
          ELSE  
            DEL = 
     1            (  DEP_SNOW_NEXT(I,K_TOP) 
     1             + DEP_SNOW_NEXT(I,K_BOT) ) / 2 
            WGT =                                        ! �ォ��̋���
     1            ( DEL - ( DEPTH_HAF(I) - FIXED_DEPTH(KK) ) )
     1              * ( KLEV(I) - K_TOP )
     1          + ( FIXED_DEPTH(KK) - DEPTH_HAF(I) )
     1              * ( K_BOT - KLEV(I) )
!
            DAT (I) =   
     1                + TMP_SNOW_NEXT(I,K_TOP)
     1                    * ( 1 - WGT / DEL )
     1                + TMP_SNOW_NEXT(I,K_BOT) 
     1                    *  WGT / DEL 
          ENDIF     
!
        ENDIF
        ENDDO 
!
!  --------------
!  > ���j�^�o�� <
!  --------------
!
#ifdef MONYOS
          CMARK = 'TMPWDxM'
          WRITE(CMARK(6:6),'(I1)') KK
          CALL MONIT_SIB ( CMARK , DAT ,INS, DELT_SNOW , ONE )  
!
          CMARK = 'CVRWDxM'
          WRITE(CMARK(6:6),'(I1)') KK
          CALL MONIT_SIB ( CMARK , CVR ,INS, DELT_SNOW , ONE )  
#endif
!
      ENDDO
!
! ================
! >> ���d�ʏ�� <<   
! ================
!
      DO KK=1,NUM_WEIGHT
!
        DAT        (:) = 0.D0 
        CVR        (:) = 0.D0        
!
        WEIGHT_TMP (:) = 0.D0    
        WEIGHT_HAF (:) = 0.D0    
        KLEV       (:) = 0 
!
!  ----------------------
!  > �z���郌�x���̌v�Z <
!  ----------------------
!      �w�背�x�����܂ޑw        KLEV 
!      ���̑w�̒������܂ł̐[��  WEIGHT_HAF 
!
        DO K=1,ISN
        DO I=1,NMAX 
          WEIGHT_TMP(I) = WEIGHT_TMP(I) + WEIGHT_SNOW(I,K) 
          IF (       KLEV(I) .EQ. 0 
     1         .AND. WEIGHT_TMP(I) .GT. FIXED_WEIGHT(KK) )  THEN
            KLEV(I) = K 
            WEIGHT_HAF(I) 
     1             = WEIGHT_TMP(I) - WEIGHT_SNOW(I,K)/2
          ENDIF
        ENDDO
        ENDDO
!
!  --------------------------
!  > ���}�Ɏg�����x���̐ݒ� <
!  --------------------------
!
        DO I=1,NMAX
        IF ( KLEV(I).GT.0 ) THEN                     ! ���}���郌�x���̂�
!
          CVR(I) = 1.
!
!   ��Ɖ��̃��x���̌���
!
          IF ( FIXED_WEIGHT(KK) .GT. WEIGHT_HAF(I) ) THEN   ! ���̑w�Ɠ��}
            K_BOT = KLEV(I) + 1 
            K_TOP = KLEV(I) 
          ELSE                                            ! ��̑w�Ɠ��} 
            K_BOT = KLEV(I) 
            K_TOP = KLEV(I) - 1 
          ENDIF
!
!    ���}
!
          IF     ( K_BOT .EQ. KLEV_SNOW(I)+1 ) THEN  ! �ŉ��w�̒�����艺
            DAT (I) = TMP_SNOW_NEXT(I,KLEV_SNOW(I)) 
!
          ELSEIF ( K_TOP .EQ. 0 ) THEN                ! �ŏ�w�̒�������
            DAT (I) =   
     1            + TMP_SNSK(I)
     1                * ( 1 - FIXED_WEIGHT(KK) / WEIGHT_HAF(I) ) ! ������̋��� 
     1            + TMP_SNOW_NEXT(I,1) 
     1                *  FIXED_WEIGHT(KK)      / WEIGHT_HAF(I)   ! �ォ��̋���
!
          ELSE  
            DEL = 
     1            (  WEIGHT_SNOW(I,K_TOP) 
     1             + WEIGHT_SNOW(I,K_BOT) ) / 2 
            WGT =                                        ! �ォ��̋���
     1            ( DEL - ( WEIGHT_HAF(I) - FIXED_WEIGHT(KK) ) )
     1              * ( KLEV(I) - K_TOP )
     1          + ( FIXED_WEIGHT(KK) - WEIGHT_HAF(I) )
     1              * ( K_BOT - KLEV(I) )
!
            DAT (I) =   
     1                + TMP_SNOW_NEXT(I,K_TOP)
     1                    * ( 1 - WGT / DEL )
     1                + TMP_SNOW_NEXT(I,K_BOT) 
     1                    *  WGT / DEL 
          ENDIF     
!
        ENDIF
        ENDDO 
!
!  --------------
!  > ���j�^�o�� <
!  --------------
!
#ifdef MONYOS
          CMARK = 'TMPWWxM'
          WRITE(CMARK(6:6),'(I1)') KK
          CALL MONIT_SIB ( CMARK , DAT ,INS, DELT_SNOW , ONE )  
!
          CMARK = 'CVRWWxM'
          WRITE(CMARK(6:6),'(I1)') KK
          CALL MONIT_SIB ( CMARK , CVR ,INS, DELT_SNOW , ONE )  
!       ENDIF
#endif
!
      ENDDO
!
      RETURN
      END
!=======================================================
      SUBROUTINE MR_SNOW_MONIT_FIXED_DEPTH 
!
      USE SIB_MONIT , ONLY : 
     1                       IMONIT_LEVEL, IMONIT_ALL
!
      IMPLICIT NONE
!
      CHARACTER( 7)  :: CMARK 
      CHARACTER(32)  :: CTITLE 
      CHARACTER(13)  :: CUNIT
!
      INTEGER,PARAMETER :: NUM_DEPTH  = 3
      INTEGER,PARAMETER :: NUM_WEIGHT = 3
!
      LOGICAL,SAVE ::  LFIRST 
      INTEGER      :: KK 
!
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'MR_SNOW_MONIT_FIXED_DEPTH 00/08' 
        LFIRST = .FALSE. 
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
      DO KK=1,NUM_DEPTH
        CMARK  = 'TMPWDxM'
        CTITLE = 'TMP SNOW AT DEPTH x'
        CUNIT  = 'K'
        WRITE(CMARK(6:6),'(I1)') KK
        WRITE(CTITLE(19:19),'(I1)') KK
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
        CMARK  = 'CVRWDxM'
        CTITLE = 'CVR SNOW AT DEPTH x'
        CUNIT  = 'K'
        WRITE(CMARK(6:6),'(I1)') KK
        WRITE(CTITLE(19:19),'(I1)') KK
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      ENDDO
!
      DO KK=1,NUM_WEIGHT
        CMARK  = 'TMPWWxM'
        CTITLE = 'TMP SNOW AT WEIGHT x'
        CUNIT  = 'K'
        WRITE(CMARK(6:6),'(I1)') KK
        WRITE(CTITLE(19:19),'(I1)') KK
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
        CMARK  = 'CVRWWxM'
        CTITLE = 'CVR SNOW AT WEIGHT x'
        CUNIT  = 'K'
        WRITE(CMARK(6:6),'(I1)') KK
        WRITE(CTITLE(19:19),'(I1)') KK
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      ENDDO
!
      ENDIF
!
      RETURN
      END