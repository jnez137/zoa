
module type_utils
! THis module should only contain methods that have no dependencies
    
    contains
 
    function real2str(val) result(strOut)
        real*8 :: val
        character(len=23) :: strOut
    
        write(strOut, '(D23.15)') val
    
      end function
    
      function str2real8(strIpt) result(val)
        use iso_fortran_env, only: real64
        character(len=*) :: strIpt
        real(kind=real64) :: val
        character(len=23) :: strR
    
        PRINT *, "strIpt is ", strIpt
    
        write(strR, *) strIpt
        strR = adjustl(strR)
        PRINT *, "strR is ", strR
        read(strR, '(D23.15)') val
        PRINT *, "Output val is ", val
    
      end function
    
      function str2int(strIpt) result(val)
        integer :: val
        character(len=*) :: strIpt
        character(len=80) :: strB
    
        write(strB, '(A3)') strIpt
        ! Not sure if this is needed
        strB = adjustl(strB)
        read(strB, '(I3)') val
    
      end function
    
      function int2str(ipt) result(strInt)
        integer :: ipt
        character(len=20) :: strInt
    
        write(strInt, '(I20)') ipt
    
        strInt = ADJUSTL(strInt)
    
      end function

      function int2char(iptInt) result(outputChar)
        integer, intent(in) :: iptInt
        character(len=80) :: outputChar
        write(outputChar, '(I3)') iptInt
    
        outputChar = adjustl(outputChar)
    
      end function      


end module