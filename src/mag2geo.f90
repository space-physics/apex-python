program mag2geo

use, intrinsic :: iso_fortran_env, only: real64
use apex, only : apex_setup,gm2gc

implicit none (type, external)

integer :: i, u, N
character(256) :: buf, nmlfn
real :: yeardec, r
real, allocatable, dimension(:) :: glat, glon, gmlat, gmlon
real(real64) :: tic, toc

namelist / input_shape / N
namelist / output / glat, glon
namelist / input / gmlat, gmlon

call get_command_argument(1, buf, status=i)
if(i/=0) error stop 'missing decimal year e.g. 2020.35'
read(buf, '(f8.4)', iostat=i) yeardec
if(i/=0) error stop 'command line should be like "./geo2mag yeardec in.nml out.nml"'

call get_command_argument(2, nmlfn, status=i)
if(i/=0) error stop 'specify input namelist file'

! -------------------------
!! read first, in case there is an IO issue, we don't want to waste time
!! initializing Apex if it will fail anyway
open(newunit=u, file=nmlfn, action='readwrite', status='old')
read(u, nml=input_shape)

allocate(glat(N), glon(N), gmlat(N), gmlon(N))

read(u, nml=input)

call cpu_time(tic)
call apex_setup(yeardec,altmax=1000.)
call cpu_time(toc)
print '(F5.1,A)', toc-tic, ' seconds to setup Apex'

call cpu_time(tic)
do i = 1,size(gmlat)
  call gm2gc(gmlat(i), gmlon(i), glat(i), glon(i))
end do
call cpu_time(toc)
print '(ES12.3,A,I8,A)', toc-tic, ' seconds to convert ', N, ' points.'

write(u, nml=output)
close(u)

end program
