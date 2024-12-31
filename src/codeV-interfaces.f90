module cmd_interfaces

    interface
    module subroutine execSUR(iptStr)
    character(len=*) :: iptStr
    end subroutine execSUR
    module subroutine setPlotWavelength(iptStr)
   character(len=*) :: iptStr
   end subroutine setPlotWavelength
   module subroutine setPlotDensity(iptStr)
   character(len=*) :: iptStr
   end subroutine setPlotDensity  
   module subroutine setPlotZernikeCoefficients(iptStr)
   character(len=*) :: iptStr
   end subroutine setPlotZernikeCoefficients 
   module subroutine ZERN_TST(iptStr)
   character(len=*) :: iptStr
   end subroutine ZERN_TST
   module subroutine execVie(iptStr)
   character(len=*) :: iptStr
   end subroutine execVie
   module subroutine execRMSPlot(iptStr)
   character(len=*) :: iptStr
   end subroutine execRMSPlot 
   module subroutine execSeidelBarChart(iptStr)
   character(len=*) :: iptStr
   end subroutine execSeidelBarChart    
   module subroutine setThickness(iptStr)
    character(len=*) :: iptStr
   end subroutine setThickness 
   module subroutine setGlass(iptStr)
    character(len=*) :: iptStr
   end subroutine setGlass    
    end interface

end module