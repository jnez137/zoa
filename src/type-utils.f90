
module type_utils
! THis module should only contain methods that have no dependencies
    
    type string
       character(len=:), allocatable :: s
    end type string    

    contains

 
    function real2str(val, precision, sci) result(strOut)
        use iso_fortran_env, only: real64, real32

        implicit none

        class(*) :: val
        real(kind=real64) :: valDP
        real(kind=real32) :: valSP
        character(len=23) :: strOut
        integer, optional :: precision
        logical, optional :: sci

        select type(val)
        type is (real(real64))
          valDP = val

          if(present(sci)) then
            write(strOut, '(D23.15)') valDP
            return
          end if

          
          if(present(precision)) then
            write(strOut, '(F9.'//trim(int2str(precision))//')') valDP
            !write(strOut, '(F9.4)') val
         else
             !
             write(strOut, '(F9.5)') valDP
         end if          
          type is (real(real32))
          valSP = val

          if(present(sci)) then
            write(strOut, '(D23.15)') valSP
            return
          end if          
          if(present(precision)) then
            write(strOut, '(F9.'//trim(int2str(precision))//')') valSP
            !write(strOut, '(F9.4)') val
         else
             !write(strOut, '(D23.15)') val
             write(strOut, '(F9.5)') valSP
         end if    

    end select
        
    
        strOut = adjustl(strOut)
    
      end function
    
      function str2real8(strIpt) result(val)
        use iso_fortran_env, only: real64
        character(len=*) :: strIpt
        real(kind=real64) :: val
        !character(len=23) :: strR
    

        read(strIpt,*) val
        ! write(strR, *) strIpt
        ! strR = adjustl(strR)
        ! PRINT *, "strR is ", strR
        ! read(strR, '(D23.15)') val
        ! read(strR, '(F9.5)') val
        ! PRINT *, "Output val is ", val
    
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
    
      function bool2str(ipt) result(strBool)

        logical :: ipt
        character(len=20) :: strBool

        if (ipt) then 
          strBool = trim(int2str(1))
        else
          strBool = trim(int2str(0))
        end if

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
      
      function blankStr(strLen) result(blnk)
        implicit none
        character(:), allocatable :: blnk
        integer :: strLen, i
    
        allocate(character(len=strLen) :: blnk)
        do i=1,strLen
            blnk(i:i) = ' '
        end do 
    
      end function


end module