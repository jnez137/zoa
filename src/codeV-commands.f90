! THis module contains Code V style commands and translates them to KDP style commands

module codeV_commands



    type zoa_cmd
      character(len=8) :: cmd
      procedure (cmdImplementation), pointer, pass(self) :: execFunc

    end type

    abstract interface
    subroutine cmdImplementation (self,iptStr)
       import zoa_cmd
       class(zoa_cmd) :: self
       character(len=*) ::iptStr
       !real, intent (in) :: z
    end subroutine cmdImplementation 
 end interface    

    character(len=4), dimension(500) :: surfCmds
    type(zoa_cmd), dimension(2) :: zoaCmds

    contains

    subroutine initializeCmds()
        ! This is called when the program is initialized (currently INITKDP.FOR)

        zoaCmds(1)%cmd = "RMD"
        zoaCmds(1)%execFunc => execRMD
        !zoaCmds(2)%cmd = 'WL'
        !zoaCmds(2)%execFunc => setWavelength


    end subroutine

    function startCodeVLensUpdateCmd(iptCmd) result(boolResult)

        character(len=*) :: iptCmd
        logical :: boolResult

        boolResult = .FALSE.

        ! IF(iptCmd.EQ.'TIT') THEN
        !         CALL setLensTitle()
        !         return
        !       END IF   
        ! IF(iptCmd.EQ.'YAN') THEN
        !         CALL setField('YAN')
        !         return
        !       END IF   
        ! IF(iptCmd.EQ.'WL') THEN
        !         CALL setWavelength()
        !         return
        !       END IF    
        ! IF(iptCmd.EQ.'SO'.OR.iptCmd.EQ.'S') then
        !         CALL setSurfaceCodeVStyle(iptCmd)
        !         return
        !       END IF          
        ! IF(isSurfCommand(iptCmd)) then
        !         CALL setSurfaceCodeVStyle(iptCmd)
        !         return
        !       END IF                         
        ! IF(iptCmd.EQ.'GO') then
        !         CALL executeGo()
        !         return
        !       END IF  
        ! select case (iptCmd)
        
        ! Temp code for interface check
        if (iptCmd == zoaCmds(1)%cmd) then
            PRINT *, "About to crash with fcn pointer?"
            call zoaCmds(1)%execFunc("Testing")
            boolResult = .TRUE.
            return
        end if

        select case (iptCmd)

        case('YAN')
            CALL setField('YAN')
            boolResult = .TRUE.
            return
        case('WL')
            CALL setWavelength()
            boolResult = .TRUE.
            return            
        case('SO','S')
            CALL setSurfaceCodeVStyle(iptCmd)
            boolResult = .TRUE.
            return            
        case('GO')
            CALL executeGo()
            boolResult = .TRUE.
            return

        case('TIT') 
            CALL setLensTitle()
            boolResult = .TRUE.
            return            
        case ('DIM')
            call setDim()
            boolResult = .TRUE.
            return 
        case ('THI')
            call setThickness()
            boolResult = .TRUE.
            return 
        case ('RDY')
            call setRadius()
            boolResult = .TRUE.
            return  
        case ('INS')
            call insertSurf()
            boolResult = .TRUE.
            return      
        case ('GLA')
            call setGlass()
            boolResult = .TRUE.
            return           
        case ('PIM')
            call setParaxialImageSolve()
            boolResult = .TRUE.
            return     
        case ('EPD')
            call setEPD()
            boolResult = .TRUE.
            return   
        case ('CUY')
            call setCurvature()
            boolResult = .TRUE.
            return             
        case ('DEL')
            call deleteStuff()
            boolResult = .TRUE.
            return                 

        case ('RED')
            call setMagSolve()
            boolResult = .TRUE.
            return  

        case ('SETC')
            call execSetCodeVCmd()
            boolResult = .TRUE.
            return              

        end select

        ! Handle Sk separately
        IF(isSurfCommand(iptCmd)) then
            CALL setSurfaceCodeVStyle(iptCmd)
            return
          END IF            
              
    end function

    subroutine execRMD(self, iptStr)
        class(zoa_cmd) :: self
        character(len=*) :: iptStr
        PRINT *, "Plumbing worked!"
        PRINT *, "IptStr is ", iptStr
        PRINT *, "CMD is ", self%cmd

    end subroutine

    subroutine execSetCodeVCmd()
        use command_utils, only : parseCommandIntoTokens
        use type_utils, only: int2str, str2real8, real2str
        use global_widgets, only: curr_lens_data, curr_par_ray_trace
        use handlers, only: updateTerminalLog
        implicit none

        integer :: surfNum
        character(len=80) :: tokens(40)
        integer :: numTokens

        include "DATMAI.INC"

        call parseCommandIntoTokens(INPUT, tokens, numTokens, ' ')
        ! This nested select statements is not sustainable.  Need a more elegant way of parsing this
        ! command and figuring out what commands to translate it to
        if(numTokens > 1 ) then
        select case(trim(tokens(2))) 
            case('MAG') ! FORMAT SET MAX X
                if(numTokens > 2) then
                    call executeCodeVLensUpdateCommand('CHG 0;TH '// &
                    real2str(curr_par_ray_trace%getObjectThicknessToSetParaxialMag( &
                    & str2real8(trim(tokens(3))),curr_lens_data)))                            
                else
                    call updateTerminalLog("No Mag Value specified.  Please try again", "red")
                end if 
                

            end select

        end if
    end subroutine

    subroutine setMagSolve()
        use command_utils, only : parseCommandIntoTokens
        use type_utils, only: int2str
        use global_widgets, only: curr_lens_data
        use handlers, only: updateTerminalLog
        implicit none

        integer :: surfNum
        character(len=80) :: tokens(40)
        integer :: numTokens

        include "DATMAI.INC"

        call parseCommandIntoTokens(INPUT, tokens, numTokens, ' ')

        call executeCodeVLensUpdateCommand('CHG 0; REDSLV '//trim(tokens(2)))          

    end subroutine

    ! Format:  DEL SOL CUY S2
    !          DEL PIM
    subroutine deleteStuff()
        use command_utils, only : parseCommandIntoTokens
        use type_utils, only: int2str
        use global_widgets, only: curr_lens_data
        use handlers, only: updateTerminalLog
        implicit none

        integer :: surfNum
        character(len=80) :: tokens(40)
        integer :: numTokens

        include "DATMAI.INC"

        call parseCommandIntoTokens(INPUT, tokens, numTokens, ' ')
        ! This nested select statements is not sustainable.  Need a more elegant way of parsing this
        ! command and figuring out what commands to translate it to
        if(numTokens > 1 ) then
        select case(trim(tokens(2))) 
            case('PIM')
                call updateTerminalLog("Deleting PIM", "blue")
                surfNum = curr_lens_data%num_surfaces - 2
                call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
                & '; TSD ')          

            case('SOL') ! Delete Solves
                if(numTokens > 2) then
                    call updateTerminalLog("Deleting Solve", "blue")
                    select case(trim(tokens(3)))
                    case('CUY')
                        if (isSurfCommand(trim(tokens(4)))) then
                            surfNum = getSurfNumFromSurfCommand(trim(tokens(4)))
                            call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
                            & '; CSDY ')                            
                        end if
                    end select
                else
                    call updateTerminalLog("No Angle Solve Specified.  Please try again", "red")
                    end if 
                

            end select

        end if

    end subroutine

    ! Format:  CUY Sk SOLVETYPE VAL
    subroutine setCurvature()
        use command_utils, only : parseCommandIntoTokens, isInputNumber
        use type_utils, only: int2str
        use handlers, only: updateTerminalLog
        implicit none

        integer :: surfNum
        character(len=80) :: tokens(40)
        integer :: numTokens

        include "DATMAI.INC"

        call parseCommandIntoTokens(INPUT, tokens, numTokens, ' ')
        if(isSurfCommand(trim(tokens(2)))) then
            surfNum = getSurfNumFromSurfCommand(trim(tokens(2)))
            if (numTokens > 2) then
               if (isInputNumber(trim(tokens(3)))) then ! FORMAT: CUY Sk VAL
                call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
                & '; CV, ' // trim(tokens(3)))
               else                 
                

               select case (trim(tokens(3)))
               case('UMY')
                PRINT *, "In the right place!  How exciting!!"
                PRINT *, "numTokens is ", numTokens
                if (numTokens > 3 ) then
                    call updateTerminalLog("Give it a try!", "blue")
                    call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
                    & '; PUY, ' // trim(tokens(4))) 
                end if

               end select 
            end if ! Tokens > 2 loop
            else
                call updateTerminalLog("No Angle Solve Specified.  Please try again", "red")
            end if
         
        else
            call updateTerminalLog("Surface not input correctly.  Should be SO or Sk where k is the surface of interest", "red")
            return
        end if          

    end subroutine

    subroutine setEPD()
        use command_utils
        use type_utils, only: real2str
        logical :: inputCheck

         if(checkCommandInput([ID_CMD_NUM], max_num_terms=1)) then
            call executeCodeVLensUpdateCommand('SAY '//real2str(getInputNumber(1)/2.0))
         end if      



        ! IF(WC.EQ.'EPD') THEN
        !     IF(DF1.EQ.0) W1=W1/2.0D0
        !     WC='SAY'
        !             END IF        

    end subroutine

    subroutine setParaxialImageSolve()
        use global_widgets, only: curr_lens_data
        use type_utils, only: int2str
        integer :: surfNum

        ! Get surface before last surface and add solve
        surfNum = curr_lens_data%num_surfaces - 2
        call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
        & '; PY, 0')            


    end subroutine


    ! format:  GLA Sk GLASSNAME
    subroutine setGlass()
        use command_utils, only : checkCommandInput, getInputNumber, parseCommandIntoTokens, isInputNumber
        use glass_manager, only: parseModelGlassEntry
        use type_utils, only: real2str, int2str
        use handlers, only: updateTerminalLog
        use iso_fortran_env, only: real64

        !character(len=*) :: iptCmd
        integer :: surfNum
        character(len=80) :: tokens(40)
        integer :: numTokens
        real(kind=real64) :: nd, vd

        include "DATMAI.INC"

        call updateTerminalLog("Starting to update GLA ", "blue" )

        call parseCommandIntoTokens(INPUT, tokens, numTokens, ' ')

        if(isSurfCommand(trim(tokens(2)))) then
            surfNum = getSurfNumFromSurfCommand(trim(tokens(2)))
            if (isInputNumber(trim(tokens(3)))) then ! Assume user entered model glass
                PRINT *, "Model Glass Entered!"
                call parseModelGlassEntry(trim(tokens(3)), nd, vd)
                call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
                & '; MODEL D'//trim(tokens(3))//','//real2str(nd)//','//real2str(vd))    
            else ! Assume it is glass name          
            
            call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
            & '; GLAK ' // trim(tokens(3)))
            end if            
        else
            call updateTerminalLog("Surface not input correctly.  Should be SO or Sk where k is the surface of interest", "red")
            return
        end if                

        

        PRINT *, "tokens(1) is ", trim(tokens(2))
        PRINT *, "tokens(2) is ", trim(tokens(3))
        

       
        ! if (checkCommandInput([ID_CMD_NUM], max_num_terms=2)) then
        !     surfNum = INT(getInputNumber(1))
        !     call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
        !     & '; RD, ' // real2str(getInputNumber(2)))
        ! end if                    

    end subroutine

    subroutine setThickness()
        use command_utils, only : parseCommandIntoTokens
        use type_utils, only: int2str
        use handlers, only: updateTerminalLog
        implicit none

        integer :: surfNum
        character(len=80) :: tokens(40)
        integer :: numTokens

        include "DATMAI.INC"

        call parseCommandIntoTokens(INPUT, tokens, numTokens, ' ')
        PRINT *, "Token is ", trim(tokens(2))
        if(isSurfCommand(trim(tokens(2)))) then
            PRINT *, "Token is ", trim(tokens(2))
            surfNum = getSurfNumFromSurfCommand(trim(tokens(2)))
            call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
            & '; TH, ' // trim(tokens(3)))          
        else
            call updateTerminalLog("Surface not input correctly.  Should be SO or Sk where k is the surface of interest", "red")
            return
        end if       

    end subroutine
    
    !Format RDY Sk Val
    subroutine setRadius()
        use command_utils, only : parseCommandIntoTokens
        use type_utils, only: int2str
        use handlers, only: updateTerminalLog
        implicit none

        integer :: surfNum
        character(len=80) :: tokens(40)
        integer :: numTokens

        include "DATMAI.INC"

        call parseCommandIntoTokens(INPUT, tokens, numTokens, ' ')

        if(isSurfCommand(trim(tokens(2)))) then
            surfNum = getSurfNumFromSurfCommand(trim(tokens(2)))
            call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
            & '; RD, ' // trim(tokens(3)))          
        else
            call updateTerminalLog("Surface not input correctly.  Should be SO or Sk where k is the surface of interest", "red")
            return
        end if             
       
    end subroutine

    subroutine insertSurf()
        use command_utils, only : checkCommandInput, getInputNumber, getQualWord
        use type_utils, only: real2str, int2str
        integer :: surfNum

        !PRINT *, "Inside insertSurf"
        ! TODO:  Add an error check for Sk in checkCommandInput

        if (checkCommandInput([ID_CMD_QUAL])) then
            surfNum = getSurfNumFromSurfCommand(trim(getQualWord()))
            call executeCodeVLensUpdateCommand('INSK, '//trim(int2str(surfNum)))
        end if            




    end subroutine



    subroutine setDim()
        use command_utils
        logical :: inputCheck

         inputCheck = checkCommandInput([ID_CMD_QUAL], qual_words=['M', 'C', 'I'], &
         &qual_only_err_msg="DIM Takes only M(mm), C(cm), or I(inches) as input")

        ! TODO:  Get qual letter and direct to correct command
        ! if (inputCheck) then
            select case (getQualWord())

            case ('M')
                call executeCodeVLensUpdateCommand("UNITS MM")
            case ('C')
                call executeCodeVLensUpdateCommand("UNITS CM")
            case ('I')
                call executeCodeVLensUpdateCommand("UNITS IN")

            end select


    end subroutine

    subroutine newLens 
        use gtk_hl_dialog
        use handlers, only: zoatabMgr, updateTerminalLog
        use globals, only: basePath
      
        implicit none  
      
      
        integer :: resp
        character(len=80), dimension(3) :: msg

        ! Temp vars
        integer :: ios, n
        character(len=200) :: line
      
        ! Step 1:  Ask user if they are sure
      
        msg(1) ="You are about to start a new lens system"
        msg(2) = "Are you sure?"
        msg(3) = "Press Cancel to abort."   
      
        resp = hl_gtk_message_dialog_show(msg, GTK_BUTTONS_OK_CANCEL, &
             & "Warning"//c_null_char)
        if (resp == GTK_RESPONSE_OK) then
          ! Ask user if they want to save current lens
          msg(1) = "Do you want to save current lens?"
          msg(2) = "Yes to add to lens database"
          msg(3) = "No to throw away"
          resp = hl_gtk_message_dialog_show(msg, GTK_BUTTONS_YES_NO, &
          & "Warning"//c_null_char)    
          if (resp == GTK_RESPONSE_YES) then    
            ! Add to database
            call PROCESKDP('LIB PUT')
          end if
      
            ! Final question!  Ask the user if they want to close current tabs
            call zoatabMgr%closeAllTabs("dummy text at present")
      
            ! Finally at the new lens process.  
      
      
            call PROCESKDP('LENS')
            call PROCESKDP('WV, 0.635')
            call PROCESKDP('UNITS MM')
            call PROCESKDP('SAY, 10.0')
            call PROCESKDP('CV, 0.0')
            call PROCESKDP('TH, 0.10E+21')
            call PROCESKDP('AIR')
            call PROCESKDP('CV, 0.0')
            call PROCESKDP('TH, 10.0')
            call PROCESKDP('REFS')
            call PROCESKDP('ASTOP')
            call PROCESKDP('AIR')
            call PROCESKDP('CV, 0.0')
            call PROCESKDP('TH, 1.0')
            call PROCESKDP('EOS')    
      
      else 
        ! If user aborted, log it
        call updateTerminalLog("New Lens Process Cancelled", "black")
      end if
      

      ! Prototype for getting this from file
      PRINT *, "attempting to open ",trim(basePath)//'Macros/newlens.zoa'
      open(unit=9, file=trim(basePath)//'Macros/newlens.zoa', iostat=ios)
      if ( ios /= 0 ) stop "Error opening file "
  
      n = 0
  
      do
          read(9, '(A)', iostat=ios) line
          if (ios /= 0) then 
            exit
          else
            call PROCESKDP(trim(line))
          end if
          n = n + 1
      end do      
      
      
      
      end subroutine    

      !TIT
      subroutine setLensTitle()
        use command_utils
        use kdp_utils, only: inLensUpdateLevel
        include "DATMAI.INC"

        call executeCodeVLensUpdateCommand('LI '// parseTitleCommand())

        ! if (inLensUpdateLevel()) then
        !     call PROCESKDP('LI '// parseTitleCommand())
        ! else
        !    call PROCESKDP('U L;LI '// parseTitleCommand()//';EOS')
        ! end if

      end subroutine

      subroutine setField(strCmd)
        use command_utils
        use type_utils, only: real2str
        use kdp_utils, only: inLensUpdateLevel
        implicit none

        character(len=3) :: strCmd
        logical :: inputCheck

        PRINT *, "Setting Field"

        inputCheck = checkCommandInput([ID_CMD_NUM])
        if (inputCheck) then

    
        select case (strCmd)
        case('YAN')
            call executeCodeVLensUpdateCommand('SCY FANG,' // real2str(getInputNumber(1)))
    
            ! if (inLensUpdateLevel()) then
            !     PRINT *, 'SCY FANG,' // real2str(getInputNumber(1))
            !     call PROCESKDP('SCY FANG,' // real2str(getInputNumber(1)))
            ! else
            !     call PROCESKDP('U L;SCY FANG, '// real2str(getInputNumber(1))//';EOS')
            ! end if

        end select
    end if

      end subroutine

      subroutine setWavelength()
        !TODO Support inputting up to 10 WL  See CV2PRG.FOR
        use command_utils
        use type_utils, only: real2str
        use kdp_utils, only: inLensUpdateLevel
        implicit none

        logical :: inputCheck


        inputCheck = checkCommandInput([ID_CMD_NUM])
        if (inputCheck) then
            
            if (inLensUpdateLevel()) then               
                call PROCESKDP('WV, ' // real2str(getInputNumber(1)/1000.0))
            else
                call PROCESKDP('U L;WV, ' // real2str(getInputNumber(1)/1000.0)//';EOS')
            end if

    end if

      end subroutine      

      subroutine executeGo()
        use kdp_utils, only: inLensUpdateLevel

        if (inLensUpdateLevel()) call PROCESKDP('EOS')

      end subroutine

      function isSurfCommand(tstCmd) result(boolResult)
        use type_utils, only: int2str
        implicit none
        character(len=*) :: tstCmd
        logical :: boolResult
        integer :: i

        boolResult = .FALSE.
        
        ! Special case:  SO
        if (tstCmd.EQ.'SO') then
            boolResult = .TRUE.
            return
        end if

        do i=1,size(surfCmds)
            surfCmds(i) = 'S'//trim(int2str(i))
            if(tstCmd.EQ.surfCmds(i)) then
                boolResult = .TRUE.
            end if

        end do



      end function

      function isCodeVCommand(tstCmd) result(boolResult)
        logical :: boolResult
        character(len=*) :: tstCmd
        character(len=3), dimension(18) :: codeVCmds
        integer :: i


        ! TODO:  Find some better way to do this.  For now, brute force it
        codeVCmds = [character(len=4) :: 'YAN', 'TIT', 'WL', 'SO','S','GO', &
        &'DIM', 'RDY', 'THI', 'INS', 'GLA', 'PIM', 'EPD', 'CUY', &
        & 'DEL', 'RED', 'SETC', 'RMD']
        boolResult = .FALSE.
        do i=1,size(codeVCmds)
            if (tstCmd.EQ.codeVCmds(i)) then
                boolResult = .TRUE.
                return
            end if
        end do
        ! If we've gotten here check if it is a surface command
        boolResult = isSurfCommand(tstCmd)

      end function

      subroutine executeCodeVLensUpdateCommand(iptCmd)
        use kdp_utils, only: inLensUpdateLevel
        implicit none
        character(len=*) :: iptCmd
        if (inLensUpdateLevel()) then               
            call PROCESKDP(iptCmd)
        else
            call PROCESKDP('U L;'// iptCmd //';EOS')
        end if
      end subroutine

      function getSurfNumFromSurfCommand(iptCmd) result(surfNum)
        use type_utils, only: str2int
        character(len=*) :: iptCmd
        integer :: surfNum

        print *, "IPTCMD is ", iptCmd
        print *, "len of iptCmd is ", len(iptCmd)

        if(len(iptCmd).EQ.1) then ! It is S, which is S1
            surfNum = 1
            return
        end if
        if(len(iptCmd).EQ.2) then
            if (iptCmd(2:2).EQ.'O') then ! 'CMD is SO
                surfNum = 0
                return
            end if
        end if

        if(len(iptCmd).GT.1) then
            surfNum = str2int(iptCmd(2:len(iptCmd)))
            return
        end if




      end function

      subroutine setLens()

            ! Here I am creating a new default lens.
            ! Not sure this is the right thing to do, but for now give it a go
            call PROCESKDP('LENS')
            call PROCESKDP('WV, 0.635')
            call PROCESKDP('UNITS MM')
            call PROCESKDP('SAY, 10.0')
            call PROCESKDP('CV, 0.0')
            call PROCESKDP('TH, 0.10E+21')
            call PROCESKDP('AIR')
            call PROCESKDP('CV, 0.0')
            call PROCESKDP('TH, 10.0')
            call PROCESKDP('REFS')
            call PROCESKDP('ASTOP')
            call PROCESKDP('AIR')
            call PROCESKDP('CV, 0.0')
            call PROCESKDP('TH, 1.0')
            call PROCESKDP('EOS')    
            call PROCESKDP('U L')
      

      end subroutine


      subroutine setSurfaceCodeVStyle(iptCmd)
        use command_utils, only : checkCommandInput, getInputNumber
        use type_utils, only: real2str, int2str
        character(len=*) :: iptCmd
        integer :: surfNum

        surfNum = getSurfNumFromSurfCommand(trim(iptCmd))

        
       
        if (checkCommandInput([ID_CMD_NUM], max_num_terms=2)) then
            call executeCodeVLensUpdateCommand('CHG '//trim(int2str(surfNum))// &
            & '; RD, ' // real2str(getInputNumber(1))//";TH, "// &
            & real2str(getInputNumber(2)))
        end if            

      end subroutine

end module