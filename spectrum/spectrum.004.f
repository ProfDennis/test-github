c------------------------------------------------------------------72->|
c------------------------------------------------------------------72->|
      Program spectrum

c----------------------------------------------------------------------
c  Version 0.004
c  Initially created May 21, 2019
c  Revised July 23, 2019
c  Revised August 18, 2020: Default 400-2000 cm-1.
c  Revised August 19, 2020: Default 400=3300 cm-1.
c  Dennis L. Lichtenberger

c  Program to create a spectrum with broadened peaks from a file 
c  containing the energies and intensities of the peaks.

c  Input is peak energies and intensities in two columns
c  Last line of input is -1 0 to signify end of data.
c  Output is the spectrum x axis and y values in two columns

c In Windows...
c First run g77setup.bat in the DOS cmd.exe window
c to set up the g77 compile environment.
c Compile with g77 -i spectrum.004.f in the DOS cmd.exe window
c Executable is then in a.exe

c In LINUX...
c Compile with gfortran spectrum.003.f
c Executable is then in a.out

c npeaks is the number of peaks
c energy, epsi are the input peak energies and intensities
c x, y is the output spectrum
c file_in is input filename (default is peaks.txt)
c file_out is the x, y values of the spectrum for input to 
c a spreadsheet
c--------------------------------------------------------------------

      implicit real*8(a-h,o-z)
      dimension energy(10000),epsi(10000)
      character*1 opted,print
      character*72 comment
      character*6 string1
      character*16 file_in
      character*16 file_out
      character*17 string2
     
c------------------------------------------------------------------72->|
c Set the input filename
c Typing return gives the default file peaks.txt
    1 write(6,*) ' The input file consists of two columns of numbers.'
      write(6,*) ' The first column is the peak frequency.'
      write(6,*) ' The second column is the peak absorbance intensity.'
      write(6,*) ' The last line contains the numbers -1 0'
      write(6,*) ' '
      write(6,*) ' Enter input peaks filename.'
      write(6,*) ' (default filename is peaks.txt)'
      write(6,806)
  806 format('  (maximum 16 characters): ',$)
      read(5,800,err=1) file_in
  800 format(a16) 
      if(file_in.eq.'')file_in='peaks.txt'
      nin=11
      open (unit=nin,file=file_in,status='old',err=1)
      write(6,*) ' Peaks will be read from ',file_in

c--------------------------------------------------------------------
c Set the output filename
c Typing return gives the default file spectrum.txt
    4 write(6,*) ' '
      write(6,*) ' Enter output spectrum filename.'
      write(6,*) ' (default filename is spectrum.txt)'
      write(6,506)
  506 format('  (maximum 16 characters): ',$)
      read(5,800,err=4) file_out
      if(file_out.eq.'')file_out='spectrum.txt'
      nout=12
      open (unit=nout,file=file_out,
     + status='unknown',form='formatted',err=97)
      write(6,*) ' Spectrum will be saved in ',file_out

c--------------------------------------------------------------------
c Get the peaks from the listing in the input

      call horizline
      write(6,801) file_in
c------------------------------------------------------------------72->|
  801 format(' Peaks written as read from file: ',a)

c read peaks and list on terminal
      write(6,*) ' '
      write(6,805)
  805 format('   Peak ',6x,' Energy ',2x,'Intensity')

      rewind(nin)
      ener=1.
      npeaks=0
      do while(ener.gt.0.0)
      read(nin,*) ener, pint
      npeaks=npeaks+1
      energy(npeaks)=ener
      epsi(npeaks)=pint
      enddo

      do 10 i=1,npeaks
   10   write(6,803) i,energy(i),epsi(i)
  803 format(2x,i5,2x,f12.3,f12.5)
      npeaks=npeaks-1
      call horizline
      write(6,807) npeaks, file_in
  807 format(i5,' peak energies and intensities listed above ',
     +'have been read from file: ',a16,/)
c     end of peaks input

c--------------------------------------------------------------------
c Set the upper and lower limits for the energy scale.
c Determine the maximum and minimum peak energy values
      pmax=energy(1)
      pmin=energy(1)
      do 11 i=2,npeaks
      if(energy(i).gt.pmax)pmax=energy(i)
      if(energy(i).lt.pmin)pmin=energy(i)
   11 continue
c Set the energy scale 10% wider than the peak scan
c and add a 50 cm-1 expansion on both sides.
      sep=pmax-pmin
      pmax=pmax+0.05*sep+50
      pmin=pmin-0.05*sep-50
c Set pmax to an integer
      nhold=nint(pmax)
      pmax=nhold
      nhold=nint(pmin)
      pmin=nhold
      if(pmin.lt.0.0)pmin=0.0
      write(6,*)' Estimated spectrum minimum and maximum values ',
     +'for the x axis are: '
      write(6,*) pmin, pmax
      write(6,*)'  '

c--------------------------------------------------------------------
c Set the low end of the scale for the x axis
c Typing return gives the default value x axis start = 400
    6 write(6,*) ' '
      write(6,*) ' Enter the x axis start value.'
      write(6,509)
  509 format('  (default x axis start value is 400): ',$)
      read(5,508,err=6) pmin
      if(pmin.le.0.0)pmin=400.0
       write(6,*) ' The x axis start value will be ',pmin
      write(6,*)'  '
      write(6,*) 'Hit enter to continue'
      read(5,800) string1

c--------------------------------------------------------------------
c Set the high end of the scale for the x axis
c Typing return gives the default value x axis end = 3300
    7 write(6,*) ' '
      write(6,*) ' Enter the x axis end value.'
      write(6,510)
  510 format('  (default x axis end value is 3300): ',$)
      read(5,508,err=7) pmax
      if(pmax.le.0.0)pmax=3300.0
       write(6,*) ' The x axis end value will be ',pmax
      write(6,*)'  '
      write(6,*) 'Hit enter to continue'
      read(5,800) string1

c--------------------------------------------------------------------
c Set the energy step size for the x axis
c Typing return gives the default value step size = 2.0
    8 write(6,*) ' '
      write(6,*) ' Enter energy step size for x axis.'
      write(6,511)
  511 format('  (default step size is 2.0): ',$)
      read(5,508,err=8) stepsize
      if(stepsize.le.0.0)stepsize=2.0
       write(6,*) ' The step size will be ',stepsize
      write(6,*)'  '
      write(6,*) 'Hit enter to continue'
      read(5,800) string1

c--------------------------------------------------------------------
c Set the linewidth for the peaks in the spectrum
c Typing return gives the default value width=20.0
    5 write(6,*) ' '
      write(6,*) ' Enter linewidth for peaks.'
      write(6,512)
  512 format('  (default linewidth is 20.0): ',$)
      read(5,508,err=5) width
  508 format(f12.5)
      if(width.le.0.0)width=20.0
       write(6,*) ' The peak linewidths will be ',width

c--------------------------------------------------------------------      
c Calculate the spectrum
      x=pmin
      npoints=0
      do while(x.le.pmax)
      npoints=npoints+1
c Calculate the contribution of each peak at x
      y=0.0
      do 12 i=1,npeaks
      var=(x-energy(i))/(width/2.0)
   12 y=y+epsi(i)/(1+var*var)
      write(nout,808,err=98) x,y
  808 format(2x,f12.4,f12.4)
      x=x+stepsize
      enddo

      write(6,810)npoints
  810 format(i5,' spectral data points have been written.')
      write(6,*)'  '
      write(6,*) ' The spectrum is saved in ',file_out
      write(6,*) ' The contents may be copied into a ',
     +'spreadsheet for plotting.'

      write(6,*)'  '
      write(6,*) 'Hit enter to end the program.'
      read(5,800) string1   

c--------------------------------------------------------------------
      close(nin)
      close(nout)
c--------------------------------------------------------------------

      stop
 
   97 write(6,96)
   96 format('Error opening file',/,
     +'Data not written')
      call pause
      stop
   98 write(6,*)' Error with file.'
      call pause
      stop
   99 write(6,*)' End of file encountered prematurely.'
      write(6,*)' Some computers require an extra blank line'
      write(6,*)' at the end of the xyz input file.'
      call pause
      stop
      end
c------------------------------------------------------------------------------
      subroutine horizline
      write(6,806)
  806 format('------------------------------------------------------')
      return
      end
c------------------------------------------------------------------------------
      subroutine pause
c ask for return to continue
      write(6,*) ' '
      write(6,801)
  801 format(' hit enter to close',$)
      read(5,800)go
  800 format(a1)
      return
      end
c------------------------------------------------------------------------------
