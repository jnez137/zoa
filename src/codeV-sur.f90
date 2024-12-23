submodule (codeV_commands) mod_sur
implicit none
contains
module procedure execSUR
    ! for now support SUR SA only
    ! New code - add abstraction of row titles and new columns of RMD GLA CCY THC GLC
                
        use command_utils, only : parseCommandIntoTokens
        use type_utils, only: int2str, blankStr, real2str
        use handlers, only: updateTerminalLog
        use mod_lens_data_manager
    
        implicit none

        !class(zoa_cmd) :: self
        integer :: ii
        character(len=80) :: tokens(40)
        character(len=256) :: fullLine
        character(len=4)  :: surfTxt
        character(len=23) :: radTxt
        character(len=23) :: thiTxt
        character(len=15) :: glaTxt
        character(len=10) :: rmdTxt
        integer :: numTokens

        !numSurfaces = curr_lens_data%num_surfaces
        !call LogTermFOR("Num Surfaces is "//trim(int2str(curr_lens_data%num_surfaces)))

        call parseCommandIntoTokens(trim(iptStr), tokens, numTokens, ' ')
        if (numTokens == 2 ) then
            if (isSurfCommand(trim(tokens(2)))) then
                !call logTermFOR("SUR Cmd here!")
                ! SA
                fullLine = blankStr(10)//"RDY"//blankStr(10)//"THI"//blankStr(5)//"RMD"//blankStr(10)//"GLA" &
                & //blankStr(10)//"CCY"//blankStr(5)//"THC"//blankStr(5)//"GLC"
                call updateTerminalLog(trim(fullLine), "black")
                ! 12/12/24:  Change this to 0 indexed surfaees
                do ii=0,ldm%getLastSurf()
                    surfTxt = ldm%getSurfName(ii)//':'
                    if (ldm%getSurfRad(ii) == 0) then
                        radTxt = 'INFINITY'
                    else ! Should abstract this with THI
                        if(ldm%getSurfRad(ii) < 0) then
                           radTxt = real2str(ldm%getSurfRad(ii),3)
                        else
                           radTxt = real2str(ldm%getSurfRad(ii),5)
                        end if
                    end if
                    if (ldm%getSurfThi(ii) > 1e10) then
                        thiTxt = 'INFINITY'
                    else
                        
                        if (ldm%getSurfThi(ii) < 0) then
                            thiTxt = real2str(ldm%getSurfThi(ii),3)
                        else
                            thiTxt = real2str(ldm%getSurfThi(ii),5)
                        end if

                    end if
                    glaTxt = ldm%getGlassName(ii)
  

                    if (glaTxt(1:4).EQ.'REFL') then
                        rmdTxt = 'REFL'//blankStr(6)
                    else
                        rmdTxt = blankStr(len(rmdTxt))
                    end if

                    glaTxt = getGlassText(ii)


                    fullLine = surfTxt//blankStr(4)//trim(radTxt)// &
                    & blankStr(4)//trim(thiTxt)//blankStr(5)//rmdTxt &
                    & //glaTxt//ldm%getCCYCodeAsStr(ii)//blankStr(5)//ldm%getTHCCodeAsStr(ii)//blankStr(5)         


                    call updateTerminalLog(trim(fullLine), "black")


                end do



            else

            call updateTerminalLog("SUR Should have a surface identifier (S0, Sk, Si, SA)", "red")
            end if

        else
            call updateTerminalLog("No Surface identifier given!  Please try again", "red")

        end if



    end procedure

    function getGlassText(surf) result(glaTxt)
        use type_utils, only: blankStr
        use mod_lens_data_manager
        implicit none
        character(len=15) :: glaTxt
        integer, intent(in) :: surf

        glaTxt = blankStr(len(glaTxt))! Initialize

        glaTxt = ldm%getGlassName(surf)
        !glaTxt = curr_lens_data%glassnames(surf)


        ! if (glaTxt(1:1).NE.' ') then
        ! !else
        !     glaTxt = trim(curr_lens_data%glassnames(surf))//'_'//trim(curr_lens_data%catalognames(surf))
        ! end if 

        if (glaTxt(1:4).EQ.'REFL') then
            glaTxt = blankStr(len(glaTxt))         
        end if   

    end function

end submodule