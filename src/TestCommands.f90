! The purpose of this is to have a baseline with a bunch of commands being run
! to catch issues during development
subroutine TestCommands
  use GLOBALS
  use kdp_utils, only: OUTKDP
  implicit none
  include "DATMAI.INC"


  if (WQ.EQ.'MANGIN') then
    CALL PROCESKDP("MAB3 ALL")
    CALL PROCESKDP('MAB3')
    CALL PROCESKDP('MAB3 I 2')
    CALL PROCESKDP('MAB3 2')
  else


  CALL PROCESKDP('MFL')
  CALL PROCESKDP('LIB P')
  CALL PROCESKDP('GLASSP')
  CALL PROCESKDP('GLASSP SCHOTT')
  !CALL PROCESKDP('CV2PRG DoubleGauss.seq')
  !CALL PROCESKDP('VIECO')

  !CALL PROCESKDP('YFAN')
  !CALL PROCESKDP('DRAWFAN')

  !CALL PROCESKDP('CV2PRG ?')
  !CALL PROCESKDP('CV2PRG ')

  CALL PROCESKDP('CV2PRG LithoKotaro.seq')
  CALL PROCESKDP('FOB 0')
  CALL PROCESKDP('RAY 1 0')
  CALL PROCESKDP('CAPFN')
  CALL PROCESKDP('FITZERN')
  CALL PROCESKDP('LISTZERN')

  ! Lens Library
  CALL PROCESKDP('LSTAT')
  CALL PROCESKDP('LIB GET 5')
  CALL PROCESKDP('LIB GET 2')

  end if

  !CALL PROCESSKDP('SHO RMSOPD')



  !CALL PROCESKDP('AST 0')
  !CALL PROCESKDP('PLTAST')
  !CALL PROCESKDP('POWSYM')


! MACRODMP

end subroutine
